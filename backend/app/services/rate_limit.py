from collections import defaultdict, deque
from datetime import datetime, timedelta, timezone
from fastapi import HTTPException
from app.core.config import settings
_hits = defaultdict(deque)
def enforce_qr_rate_limit(client_ip: str):
    now = datetime.now(timezone.utc); cutoff = now - timedelta(minutes=1); bucket = _hits[client_ip]
    while bucket and bucket[0] < cutoff: bucket.popleft()
    if len(bucket) >= settings.public_qr_rate_limit_per_minute:
        raise HTTPException(status_code=429, detail="Demasiados intentos de registro. Intenta nuevamente en un momento.")
    bucket.append(now)
