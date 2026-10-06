from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    app_name: str = "Community Attendance API"
    environment: str = "development"
    database_url: str = "postgresql+psycopg://attendance:attendance@localhost:5432/attendance"
    jwt_secret: str = "CHANGE_ME"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 480
    cors_origins: str = "*"
    public_qr_rate_limit_per_minute: int = 60
    first_admin_username: str = "admin"
    first_admin_password: str = "Admin123!"
    first_admin_full_name: str = "Administrador"
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")
    @property
    def cors_origins_list(self) -> list[str]:
        return ["*"] if self.cors_origins.strip() == "*" else [x.strip() for x in self.cors_origins.split(",") if x.strip()]
@lru_cache
def get_settings() -> Settings:
    return Settings()
settings = get_settings()
