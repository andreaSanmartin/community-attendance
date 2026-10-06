import uuid
from fastapi import APIRouter,Depends,HTTPException,Query
from sqlalchemy import select,or_
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.youth import Youth
from app.models.tribe import Tribe
from app.models.project import Project
from app.models.user import AppUser
from app.schemas.youth import YouthCreate,YouthUpdate,YouthOut
from app.api.deps import require_staff
from app.services.audit import audit
router=APIRouter(prefix="/api/youth",tags=["Jóvenes"])
def validate_links(db,tribe_id,project_id):
    tribe=db.get(Tribe,tribe_id)
    if not tribe or not tribe.is_active: raise HTTPException(status_code=400,detail="Tribu inválida o inactiva")
    if project_id:
        p=db.get(Project,project_id)
        if not p or not p.is_active: raise HTTPException(status_code=400,detail="Proyecto inválido o inactivo")
        if p.tribe_id and p.tribe_id!=tribe_id: raise HTTPException(status_code=400,detail="El proyecto no pertenece a la tribu seleccionada")
@router.get("",response_model=list[YouthOut])
def list_youth(search:str|None=Query(default=None,max_length=120),tribe_id:uuid.UUID|None=None,project_id:uuid.UUID|None=None,include_inactive:bool=False,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    stmt=select(Youth).order_by(Youth.full_name)
    if search:
        like=f"%{search.strip()}%"; stmt=stmt.where(or_(Youth.full_name.ilike(like),Youth.phone.ilike(like)))
    if tribe_id: stmt=stmt.where(Youth.tribe_id==tribe_id)
    if project_id: stmt=stmt.where(Youth.project_id==project_id)
    if not include_inactive: stmt=stmt.where(Youth.is_active==True)
    return list(db.scalars(stmt))
@router.get("/{youth_id}",response_model=YouthOut)
def get_youth(youth_id:uuid.UUID,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    y=db.get(Youth,youth_id)
    if not y: raise HTTPException(status_code=404,detail="Joven no encontrado")
    return y
@router.post("",response_model=YouthOut,status_code=201)
def create_youth(payload:YouthCreate,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    validate_links(db,payload.tribe_id,payload.project_id); y=Youth(**payload.model_dump(),created_by=user.id); db.add(y); db.flush(); audit(db,"CREATE","YOUTH",y.id,user.id); db.commit(); db.refresh(y); return y
@router.put("/{youth_id}",response_model=YouthOut)
def update_youth(youth_id:uuid.UUID,payload:YouthUpdate,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    y=db.get(Youth,youth_id)
    if not y: raise HTTPException(status_code=404,detail="Joven no encontrado")
    data=payload.model_dump(exclude_unset=True); validate_links(db,data.get("tribe_id",y.tribe_id),data.get("project_id",y.project_id))
    for k,v in data.items(): setattr(y,k,v)
    audit(db,"UPDATE","YOUTH",y.id,user.id); db.commit(); db.refresh(y); return y
@router.delete("/{youth_id}")
def deactivate_youth(youth_id:uuid.UUID,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    y=db.get(Youth,youth_id)
    if not y: raise HTTPException(status_code=404,detail="Joven no encontrado")
    y.is_active=False; audit(db,"DEACTIVATE","YOUTH",y.id,user.id); db.commit(); return {"message":"Joven desactivado"}
@router.post("/{youth_id}/regenerate-qr",response_model=YouthOut)
def regenerate_qr(youth_id:uuid.UUID,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    y=db.get(Youth,youth_id)
    if not y: raise HTTPException(status_code=404,detail="Joven no encontrado")
    y.qr_token=uuid.uuid4(); audit(db,"REGENERATE_QR","YOUTH",y.id,user.id); db.commit(); db.refresh(y); return y
