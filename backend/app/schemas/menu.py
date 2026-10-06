from pydantic import BaseModel

class MenuItemOut(BaseModel):
    key: str
    label: str
    description: str | None = None
    icon: str

class UserMenuPermissionOut(MenuItemOut):
    enabled: bool

class UserMenuPermissionUpdate(BaseModel):
    menu_keys: list[str]
