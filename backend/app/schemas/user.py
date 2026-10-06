import uuid
from pydantic import BaseModel, ConfigDict, Field
class UserCreate(BaseModel):
    full_name: str=Field(min_length=2,max_length=120)
    username: str=Field(min_length=3,max_length=60)
    password: str=Field(min_length=8,max_length=128)
    role: str="COORDINATOR"
class UserUpdate(BaseModel):
    full_name: str|None=Field(default=None,min_length=2,max_length=120)
    role: str|None=None
    is_active: bool|None=None
class UserResetPassword(BaseModel):
    new_password: str=Field(min_length=8,max_length=128)
    force_change: bool=True
class UserOut(BaseModel):
    model_config=ConfigDict(from_attributes=True)
    id: uuid.UUID; full_name: str; username: str; role: str; is_active: bool; must_change_password: bool
