import uuid
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base
class Youth(Base):
    __tablename__ = "youth"
    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    full_name: Mapped[str] = mapped_column(String(120), nullable=False, index=True)
    phone: Mapped[str] = mapped_column(String(25), nullable=False, index=True)
    tribe_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("tribe.id", ondelete="RESTRICT"), nullable=False, index=True)
    project_id: Mapped[uuid.UUID|None] = mapped_column(ForeignKey("project.id", ondelete="SET NULL"), nullable=True, index=True)
    qr_token: Mapped[uuid.UUID] = mapped_column(unique=True, index=True, default=uuid.uuid4, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_by: Mapped[uuid.UUID|None] = mapped_column(ForeignKey("app_user.id", ondelete="SET NULL"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
