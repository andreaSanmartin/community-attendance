import uuid
from fastapi import APIRouter,Depends,HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.project import Project
from app.models.tribe import Tribe
from app.models.user import AppUser
from app.schemas.project import ProjectCreate,ProjectUpdate,ProjectOut
from app.api.deps import require_staff
from app.services.audit import audit
router=APIRouter(prefix="/api/projects",tags=["Proyectos"])
@router.get("",response_model=list[ProjectOut])
def list_projects(tribe_id:uuid.UUID|None=None,include_inactive:bool=False,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    stmt=select(Project).order_by(Project.name)
    if tribe_id: stmt=stmt.where(Project.tribe_id==tribe_id)
    if not include_inactive: stmt=stmt.where(Project.is_active==True)
    return list(db.scalars(stmt))
@router.post("",response_model=ProjectOut,status_code=201)
def create_project(payload:ProjectCreate,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    if payload.tribe_id and not db.get(Tribe,payload.tribe_id): raise HTTPException(status_code=400,detail="Tribu inválida")
    p=Project(**payload.model_dump()); db.add(p); db.flush(); audit(db,"CREATE","PROJECT",p.id,user.id); db.commit(); db.refresh(p); return p
@router.put("/{project_id}",response_model=ProjectOut)
def update_project(project_id:uuid.UUID,payload:ProjectUpdate,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    p=db.get(Project,project_id)
    if not p: raise HTTPException(status_code=404,detail="Proyecto no encontrado")
    data=payload.model_dump(exclude_unset=True)
    if data.get("tribe_id") and not db.get(Tribe,data["tribe_id"]): raise HTTPException(status_code=400,detail="Tribu inválida")
    for k,v in data.items(): setattr(p,k,v)
    audit(db,"UPDATE","PROJECT",p.id,user.id); db.commit(); db.refresh(p); return p
@router.delete("/{project_id}")
def deactivate_project(project_id:uuid.UUID,db:Session=Depends(get_db),user:AppUser=Depends(require_staff)):
    p=db.get(Project,project_id)
    if not p: raise HTTPException(status_code=404,detail="Proyecto no encontrado")
    p.is_active=False; audit(db,"DEACTIVATE","PROJECT",p.id,user.id); db.commit(); return {"message":"Proyecto desactivado"}
