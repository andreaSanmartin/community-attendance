import uuid
from pydantic import BaseModel, ConfigDict, Field
class YouthCreate(BaseModel):
    full_name: str=Field(min_length=2,max_length=120)
    phone: str=Field(min_length=5,max_length=25)
    tribe_id: uuid.UUID
    project_id: uuid.UUID|None=None
class YouthUpdate(BaseModel):
    full_name: str|None=Field(default=None,min_length=2,max_length=120)
    phone: str|None=Field(default=None,min_length=5,max_length=25)
    tribe_id: uuid.UUID|None=None
    project_id: uuid.UUID|None=None
    is_active: bool|None=None
class YouthOut(BaseModel):
    model_config=ConfigDict(from_attributes=True)
    id: uuid.UUID; full_name: str; phone: str; tribe_id: uuid.UUID; project_id: uuid.UUID|None; qr_token: uuid.UUID; is_active: bool
