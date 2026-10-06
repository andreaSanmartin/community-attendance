from datetime import date,datetime,timezone
from fastapi import APIRouter,Depends,HTTPException,Request
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.attendance import Attendance
from app.models.youth import Youth
from app.models.tribe import Tribe
from app.models.project import Project
from app.models.user import AppUser
from app.schemas.attendance import QRCheckInRequest,QRCheckInResponse,ManualAttendanceRequest,AttendanceOut
from app.api.deps import require_staff
from app.services.audit import audit
from app.services.rate_limit import enforce_qr_rate_limit
router=APIRouter(prefix="/api/attendance",tags=["Asistencia"])
@router.post("/qr",response_model=QRCheckInResponse,summary="Registrar asistencia por QR sin iniciar sesión")
def check_in_qr(payload:QRCheckInRequest,request:Request,db:Session=Depends(get_db)):
    client_ip=request.client.host if request.client else "unknown"; enforce_qr_rate_limit(client_ip)
    y=db.scalar(select(Youth).where(Youth.qr_token==payload.qr_token,Youth.is_active==True))
    if not y: raise HTTPException(status_code=404,detail="Código QR inválido o joven inactivo")
    today=date.today()
    if db.scalar(select(Attendance).where(Attendance.youth_id==y.id,Attendance.attendance_date==today)):
        raise HTTPException(status_code=409,detail="Este joven ya registró su asistencia hoy")
    a=Attendance(youth_id=y.id,attendance_date=today,registered_at=datetime.now(timezone.utc),source="QR")
    db.add(a); audit(db,"QR_CHECK_IN","YOUTH",y.id,None,{"source":"QR"})
    try: db.commit()
    except IntegrityError:
        db.rollback(); raise HTTPException(status_code=409,detail="Este joven ya registró su asistencia hoy")
    db.refresh(a); tribe=db.get(Tribe,y.tribe_id); project=db.get(Project,y.project_id) if y.project_id else None
    return QRCheckInResponse(message="¡Asistencia registrada!",youth_id=y.id,full_name=y.full_name,tribe_name=tribe.name if tribe else "",project_name=project.name if project else None,attendance_date=a.attendance_date,registered_at=a.registered_at)
@router.post("/manual")
def manual_check_in(payload:ManualAttendanceRequest,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    target=payload.attendance_date or date.today(); inserted=[]; duplicate=[]; invalid=[]
    for youth_id in set(payload.youth_ids):
        y=db.get(Youth,youth_id)
        if not y or not y.is_active: invalid.append(str(youth_id)); continue
        if db.scalar(select(Attendance).where(Attendance.youth_id==youth_id,Attendance.attendance_date==target)):
            duplicate.append(str(youth_id)); continue
        db.add(Attendance(youth_id=youth_id,attendance_date=target,source="MANUAL",registered_by=user.id)); inserted.append(str(youth_id)); audit(db,"MANUAL_CHECK_IN","YOUTH",youth_id,user.id,{"attendance_date":str(target)})
    db.commit(); return {"message":"Asistencia procesada","attendance_date":target,"registered":inserted,"already_registered":duplicate,"not_found_or_inactive":invalid}
@router.get("/today",response_model=list[AttendanceOut])
def today_attendance(db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    return list(db.scalars(select(Attendance).where(Attendance.attendance_date==date.today()).order_by(Attendance.registered_at.desc())))
