from pydantic import BaseModel, Field
class LoginRequest(BaseModel):
    username: str
    password: str
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    must_change_password: bool
    role: str
    full_name: str
class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str = Field(min_length=8, max_length=128)
