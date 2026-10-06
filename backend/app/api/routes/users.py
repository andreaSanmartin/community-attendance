import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, delete
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import AppUser
from app.models.menu import MenuItem, UserMenuPermission
from app.schemas.user import UserCreate, UserUpdate, UserResetPassword, UserOut
from app.schemas.menu import UserMenuPermissionOut, UserMenuPermissionUpdate
from app.api.deps import require_admin
from app.core.security import hash_password
from app.services.audit import audit

router = APIRouter(prefix='/api/users', tags=['Usuarios'])

@router.get('', response_model=list[UserOut])
def list_users(include_inactive: bool = False, db: Session = Depends(get_db), admin: AppUser = Depends(require_admin)):
    stmt = select(AppUser).order_by(AppUser.full_name)
    if not include_inactive:
        stmt = stmt.where(AppUser.is_active == True)
    return list(db.scalars(stmt))

@router.post('', response_model=UserOut, status_code=201)
def create_user(payload: UserCreate, db: Session = Depends(get_db), admin: AppUser = Depends(require_admin)):
    role = 'SUPER_ADMIN' if payload.role == 'ADMIN' else payload.role
    if role not in {'SUPER_ADMIN', 'COORDINATOR'}:
        raise HTTPException(status_code=400, detail='Rol inválido')
    if db.scalar(select(AppUser).where(AppUser.username == payload.username)):
        raise HTTPException(status_code=409, detail='El usuario ya existe')
    user = AppUser(full_name=payload.full_name, username=payload.username, password_hash=hash_password(payload.password), role=role, must_change_password=True)
    db.add(user); db.flush()
    audit(db, 'CREATE', 'APP_USER', user.id, admin.id)
    db.commit(); db.refresh(user)
    return user

@router.put('/{user_id}', response_model=UserOut)
def update_user(user_id: uuid.UUID, payload: UserUpdate, db: Session = Depends(get_db), admin: AppUser = Depends(require_admin)):
    user = db.get(AppUser, user_id)
    if not user:
        raise HTTPException(status_code=404, detail='Usuario no encontrado')
    data = payload.model_dump(exclude_unset=True)
    if data.get('role') == 'ADMIN': data['role'] = 'SUPER_ADMIN'
    if data.get('role') and data['role'] not in {'SUPER_ADMIN', 'COORDINATOR'}:
        raise HTTPException(status_code=400, detail='Rol inválido')
    if user.id == admin.id and data.get('is_active') is False:
        raise HTTPException(status_code=400, detail='No puedes desactivar tu propio usuario')
    for key, value in data.items(): setattr(user, key, value)
    audit(db, 'UPDATE', 'APP_USER', user.id, admin.id)
    db.commit(); db.refresh(user)
    return user

@router.post('/{user_id}/reset-password')
def reset_password(user_id: uuid.UUID, payload: UserResetPassword, db: Session = Depends(get_db), admin: AppUser = Depends(require_admin)):
    user = db.get(AppUser, user_id)
    if not user: raise HTTPException(status_code=404, detail='Usuario no encontrado')
    user.password_hash = hash_password(payload.new_password)
    user.must_change_password = payload.force_change
    audit(db, 'RESET_PASSWORD', 'APP_USER', user.id, admin.id)
    db.commit()
    return {'message': 'Contraseña restablecida'}

@router.get('/{user_id}/permissions', response_model=list[UserMenuPermissionOut])
def get_permissions(user_id: uuid.UUID, db: Session = Depends(get_db), admin: AppUser = Depends(require_admin)):
    user = db.get(AppUser, user_id)
    if not user: raise HTTPException(status_code=404, detail='Usuario no encontrado')
    menu_items = list(db.scalars(select(MenuItem).where(MenuItem.is_active == True).order_by(MenuItem.sort_order)))
    enabled_ids = set(db.scalars(select(UserMenuPermission.menu_item_id).where(UserMenuPermission.user_id == user_id)))
    all_enabled = user.role in {'SUPER_ADMIN', 'ADMIN'}
    return [UserMenuPermissionOut(key=m.key, label=m.label, description=m.description, icon=m.icon, enabled=(all_enabled or m.id in enabled_ids)) for m in menu_items]

@router.put('/{user_id}/permissions')
def update_permissions(user_id: uuid.UUID, payload: UserMenuPermissionUpdate, db: Session = Depends(get_db), admin: AppUser = Depends(require_admin)):
    user = db.get(AppUser, user_id)
    if not user: raise HTTPException(status_code=404, detail='Usuario no encontrado')
    if user.role in {'SUPER_ADMIN', 'ADMIN'}:
        raise HTTPException(status_code=400, detail='Los super administradores siempre tienen acceso a todos los menús')
    menu_items = list(db.scalars(select(MenuItem).where(MenuItem.key.in_(set(payload.menu_keys)), MenuItem.is_active == True))) if payload.menu_keys else []
    valid_keys = {m.key for m in menu_items}
    invalid = set(payload.menu_keys) - valid_keys
    if invalid:
        raise HTTPException(status_code=400, detail=f'Menús inválidos: {", ".join(sorted(invalid))}')
    db.execute(delete(UserMenuPermission).where(UserMenuPermission.user_id == user_id))
    for menu in menu_items:
        db.add(UserMenuPermission(user_id=user_id, menu_item_id=menu.id))
    audit(db, 'UPDATE_MENU_PERMISSIONS', 'APP_USER', user.id, admin.id, {'menu_keys': sorted(valid_keys)})
    db.commit()
    return {'message': 'Permisos actualizados', 'menu_keys': sorted(valid_keys)}

@router.delete('/{user_id}')
def deactivate_user(user_id: uuid.UUID, db: Session = Depends(get_db), admin: AppUser = Depends(require_admin)):
    user = db.get(AppUser, user_id)
    if not user: raise HTTPException(status_code=404, detail='Usuario no encontrado')
    if user.id == admin.id: raise HTTPException(status_code=400, detail='No puedes desactivar tu propio usuario')
    user.is_active = False
    audit(db, 'DEACTIVATE', 'APP_USER', user.id, admin.id)
    db.commit()
    return {'message': 'Usuario desactivado'}
