from datetime import date,timedelta
import uuid
from fastapi import APIRouter,Depends,Query
from sqlalchemy import select,func
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.attendance import Attendance
from app.models.youth import Youth
from app.models.tribe import Tribe
from app.models.project import Project
from app.models.user import AppUser
from app.api.deps import require_staff
router=APIRouter(prefix="/api/reports",tags=["Reportes"])
def week_start(d:date)->date: return d-timedelta(days=d.weekday())
@router.get("/summary")
def summary(db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    today=date.today(); start=week_start(today); end=start+timedelta(days=7)
    return {"date":today,"week_start":start,"total_active_youth":db.scalar(select(func.count()).select_from(Youth).where(Youth.is_active==True)) or 0,"today_attendance":db.scalar(select(func.count()).select_from(Attendance).where(Attendance.attendance_date==today)) or 0,"week_attendance":db.scalar(select(func.count()).select_from(Attendance).where(Attendance.attendance_date>=start,Attendance.attendance_date<end)) or 0,"unique_youth_this_week":db.scalar(select(func.count(func.distinct(Attendance.youth_id))).where(Attendance.attendance_date>=start,Attendance.attendance_date<end)) or 0}
@router.get("/weekly")
def weekly(start_date:date|None=None,tribe_id:uuid.UUID|None=None,project_id:uuid.UUID|None=None,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    start=week_start(start_date or date.today()); end=start+timedelta(days=7)
    stmt=(select(Youth.id.label("youth_id"),Youth.full_name,Tribe.name.label("tribe_name"),Project.name.label("project_name"),func.count(Attendance.id).label("attendance_count")).join(Attendance,Attendance.youth_id==Youth.id).join(Tribe,Tribe.id==Youth.tribe_id).outerjoin(Project,Project.id==Youth.project_id).where(Attendance.attendance_date>=start,Attendance.attendance_date<end))
    if tribe_id: stmt=stmt.where(Youth.tribe_id==tribe_id)
    if project_id: stmt=stmt.where(Youth.project_id==project_id)
    stmt=stmt.group_by(Youth.id,Youth.full_name,Tribe.name,Project.name).order_by(func.count(Attendance.id).desc(),Youth.full_name)
    rows=db.execute(stmt).all(); return {"week_start":start,"week_end":end-timedelta(days=1),"items":[{"youth_id":r.youth_id,"full_name":r.full_name,"tribe_name":r.tribe_name,"project_name":r.project_name,"attendance_count":r.attendance_count} for r in rows]}
@router.get("/absent")
def absent_this_week(tribe_id:uuid.UUID|None=None,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    start=week_start(date.today()); end=start+timedelta(days=7); attended=select(Attendance.youth_id).where(Attendance.attendance_date>=start,Attendance.attendance_date<end)
    stmt=select(Youth.id,Youth.full_name,Youth.phone,Tribe.name.label("tribe_name")).join(Tribe,Tribe.id==Youth.tribe_id).where(Youth.is_active==True,Youth.id.not_in(attended)).order_by(Tribe.name,Youth.full_name)
    if tribe_id: stmt=stmt.where(Youth.tribe_id==tribe_id)
    return [{"youth_id":r.id,"full_name":r.full_name,"phone":r.phone,"tribe_name":r.tribe_name} for r in db.execute(stmt).all()]
@router.get("/by-tribe")
def by_tribe(start_date:date|None=Query(default=None),end_date:date|None=Query(default=None),db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    start=start_date or week_start(date.today()); end=end_date or date.today()
    stmt=(select(Tribe.id,Tribe.name,func.count(Attendance.id).label("attendance_count")).join(Youth,Youth.tribe_id==Tribe.id).outerjoin(Attendance,(Attendance.youth_id==Youth.id)&(Attendance.attendance_date>=start)&(Attendance.attendance_date<=end)).group_by(Tribe.id,Tribe.name).order_by(Tribe.name))
    return [{"tribe_id":r.id,"tribe_name":r.name,"attendance_count":r.attendance_count} for r in db.execute(stmt).all()]
