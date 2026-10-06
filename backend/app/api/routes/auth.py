from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import AppUser
from app.schemas.auth import LoginRequest, TokenResponse, ChangePasswordRequest
from app.schemas.user import UserOut
from app.core.security import verify_password, create_access_token, hash_password
from app.api.deps import get_current_user
from app.services.audit import audit
router=APIRouter(prefix="/api/auth", tags=["Auth"])
@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session=Depends(get_db)):
    user=db.scalar(select(AppUser).where(AppUser.username==payload.username))
    if not user or not user.is_active or not verify_password(payload.password,user.password_hash):
        raise HTTPException(status_code=401,detail="Usuario o contraseña incorrectos")
    token=create_access_token(str(user.id),user.role); audit(db,"LOGIN","APP_USER",user.id,user.id); db.commit()
    return TokenResponse(access_token=token,must_change_password=user.must_change_password,role=user.role,full_name=user.full_name)
@router.get("/me",response_model=UserOut)
def me(user:AppUser=Depends(get_current_user)): return user
@router.post("/change-password")
def change_password(payload:ChangePasswordRequest,db:Session=Depends(get_db),user:AppUser=Depends(get_current_user)):
    if not verify_password(payload.current_password,user.password_hash): raise HTTPException(status_code=400,detail="Contraseña actual incorrecta")
    user.password_hash=hash_password(payload.new_password); user.must_change_password=False; audit(db,"CHANGE_PASSWORD","APP_USER",user.id,user.id); db.commit()
    return {"message":"Contraseña actualizada"}


@router.get('/menu')
def current_menu(db: Session = Depends(get_db), user: AppUser = Depends(get_current_user)):
    from app.models.menu import MenuItem, UserMenuPermission
    items = list(db.scalars(select(MenuItem).where(MenuItem.is_active == True).order_by(MenuItem.sort_order)))
    if user.role in {'SUPER_ADMIN', 'ADMIN'}:
        return [{'key': m.key, 'label': m.label, 'description': m.description, 'icon': m.icon} for m in items]
    allowed_ids = set(db.scalars(select(UserMenuPermission.menu_item_id).where(UserMenuPermission.user_id == user.id)))
    return [{'key': m.key, 'label': m.label, 'description': m.description, 'icon': m.icon} for m in items if m.id in allowed_ids]
