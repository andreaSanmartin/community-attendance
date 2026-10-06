import uuid
from pydantic import BaseModel, ConfigDict, Field
class TribeCreate(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    description: str|None = Field(default=None, max_length=250)
class TribeUpdate(BaseModel):
    name: str|None = Field(default=None, min_length=1, max_length=80)
    description: str|None = Field(default=None, max_length=250)
    is_active: bool|None = None
class TribeOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID; name: str; description: str|None; is_active: bool
