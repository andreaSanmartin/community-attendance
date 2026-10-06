import uuid
from pydantic import BaseModel, ConfigDict, Field
class ProjectCreate(BaseModel):
    name: str = Field(min_length=1,max_length=100)
    tribe_id: uuid.UUID|None=None
    description: str|None = Field(default=None,max_length=250)
class ProjectUpdate(BaseModel):
    name: str|None=Field(default=None,min_length=1,max_length=100)
    tribe_id: uuid.UUID|None=None
    description: str|None=Field(default=None,max_length=250)
    is_active: bool|None=None
class ProjectOut(BaseModel):
    model_config=ConfigDict(from_attributes=True)
    id: uuid.UUID; name: str; tribe_id: uuid.UUID|None; description: str|None; is_active: bool
