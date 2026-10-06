import uuid
from datetime import date, datetime
from pydantic import BaseModel, ConfigDict, Field
class QRCheckInRequest(BaseModel): qr_token: uuid.UUID
class ManualAttendanceRequest(BaseModel):
    youth_ids: list[uuid.UUID]=Field(min_length=1)
    attendance_date: date|None=None
class AttendanceOut(BaseModel):
    model_config=ConfigDict(from_attributes=True)
    id: uuid.UUID; youth_id: uuid.UUID; attendance_date: date; registered_at: datetime; source: str; registered_by: uuid.UUID|None
class QRCheckInResponse(BaseModel):
    message: str; youth_id: uuid.UUID; full_name: str; tribe_name: str; project_name: str|None; attendance_date: date; registered_at: datetime
