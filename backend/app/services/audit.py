from sqlalchemy.orm import Session
from app.models.audit import AuditLog
def audit(db: Session, action: str, entity_type: str, entity_id=None, user_id=None, details: dict|None=None):
    db.add(AuditLog(action=action, entity_type=entity_type, entity_id=entity_id, user_id=user_id, details=details))
