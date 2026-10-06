import uuid
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from app.core.config import settings
from app.db.session import get_db
from app.models.user import AppUser
bearer = HTTPBearer(auto_error=False)
def get_current_user(credentials: HTTPAuthorizationCredentials|None=Depends(bearer), db: Session=Depends(get_db)) -> AppUser:
    if not credentials: raise HTTPException(status_code=401, detail="No autenticado")
    try:
        payload = jwt.decode(credentials.credentials, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        user_id = uuid.UUID(payload["sub"])
    except (JWTError, KeyError, ValueError):
        raise HTTPException(status_code=401, detail="Token inválido")
    user = db.get(AppUser, user_id)
    if not user or not user.is_active: raise HTTPException(status_code=401, detail="Usuario inválido o inactivo")
    return user
def require_admin(user: AppUser=Depends(get_current_user)) -> AppUser:
    if user.role not in {"SUPER_ADMIN", "ADMIN"}: raise HTTPException(status_code=403, detail="Se requiere rol ADMIN")
    return user
def require_staff(user: AppUser=Depends(get_current_user)) -> AppUser:
    if user.role not in {"ADMIN","COORDINATOR"}: raise HTTPException(status_code=403, detail="Permiso insuficiente")
    return user
