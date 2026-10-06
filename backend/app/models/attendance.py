import uuid
from datetime import datetime, date
from sqlalchemy import String, Date, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base
class Attendance(Base):
    __tablename__ = "attendance"
    __table_args__ = (UniqueConstraint("youth_id", "attendance_date", name="uq_attendance_youth_date"),)
    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    youth_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("youth.id", ondelete="RESTRICT"), nullable=False, index=True)
    attendance_date: Mapped[date] = mapped_column(Date, nullable=False, default=date.today, index=True)
    registered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)
    source: Mapped[str] = mapped_column(String(10), nullable=False)
    registered_by: Mapped[uuid.UUID|None] = mapped_column(ForeignKey("app_user.id", ondelete="SET NULL"), nullable=True)
    notes: Mapped[str|None] = mapped_column(String(250))
