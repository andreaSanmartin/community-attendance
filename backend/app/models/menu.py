import uuid
from sqlalchemy import String, Boolean, ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class MenuItem(Base):
    __tablename__ = 'menu_item'
    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    key: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    label: Mapped[str] = mapped_column(String(80), nullable=False)
    description: Mapped[str | None] = mapped_column(String(200), nullable=True)
    icon: Mapped[str] = mapped_column(String(50), nullable=False, default='apps')
    sort_order: Mapped[int] = mapped_column(nullable=False, default=0)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

class UserMenuPermission(Base):
    __tablename__ = 'user_menu_permission'
    __table_args__ = (UniqueConstraint('user_id', 'menu_item_id', name='uq_user_menu_permission'),)
    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey('app_user.id', ondelete='CASCADE'), nullable=False, index=True)
    menu_item_id: Mapped[uuid.UUID] = mapped_column(ForeignKey('menu_item.id', ondelete='CASCADE'), nullable=False, index=True)
