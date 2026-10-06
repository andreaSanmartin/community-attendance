import uuid
from fastapi import APIRouter,Depends,HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.tribe import Tribe
from app.models.youth import Youth
from app.models.user import AppUser
from app.schemas.tribe import TribeCreate,TribeUpdate,TribeOut
from app.api.deps import require_staff
from app.services.audit import audit
router=APIRouter(prefix="/api/tribes",tags=["Tribus"])
@router.get("",response_model=list[TribeOut])
def list_tribes(include_inactive:bool=False,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    stmt=select(Tribe).order_by(Tribe.name)
    if not include_inactive: stmt=stmt.where(Tribe.is_active==True)
    return list(db.scalars(stmt))
@router.post("",response_model=TribeOut,status_code=201)
def create_tribe(payload:TribeCreate,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    if db.scalar(select(Tribe).where(Tribe.name==payload.name)): raise HTTPException(status_code=409,detail="Ya existe una tribu con ese nombre")
    tribe=Tribe(**payload.model_dump()); db.add(tribe); db.flush(); audit(db,"CREATE","TRIBE",tribe.id,user.id); db.commit(); db.refresh(tribe); return tribe
@router.put("/{tribe_id}",response_model=TribeOut)
def update_tribe(tribe_id:uuid.UUID,payload:TribeUpdate,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    tribe=db.get(Tribe,tribe_id)
    if not tribe: raise HTTPException(status_code=404,detail="Tribu no encontrada")
    for k,v in payload.model_dump(exclude_unset=True).items(): setattr(tribe,k,v)
    audit(db,"UPDATE","TRIBE",tribe.id,user.id); db.commit(); db.refresh(tribe); return tribe
@router.delete("/{tribe_id}")
def deactivate_tribe(tribe_id:uuid.UUID,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    tribe=db.get(Tribe,tribe_id)
    if not tribe: raise HTTPException(status_code=404,detail="Tribu no encontrada")
    if db.scalar(select(Youth.id).where(Youth.tribe_id==tribe_id,Youth.is_active==True).limit(1)): raise HTTPException(status_code=409,detail="La tribu tiene jóvenes activos")
    tribe.is_active=False; audit(db,"DEACTIVATE","TRIBE",tribe.id,user.id); db.commit(); return {"message":"Tribu desactivada"}
