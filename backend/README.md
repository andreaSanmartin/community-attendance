# Community Attendance - Backend

Backend funcional para registro de jóvenes, tribus, proyectos/equipos, usuarios, asistencia por QR pública, asistencia manual autenticada y reportes.

## Stack
- Python 3.12
- FastAPI
- PostgreSQL
- SQLAlchemy 2
- JWT
- Docker / Docker Compose

## Reglas
- Escaneo QR sin login.
- Asistencia manual con login.
- QR con UUID opaco, sin nombre ni celular.
- Una asistencia por joven y día.
- Eliminación lógica para conservar historial.
- ADMIN gestiona usuarios; ADMIN y COORDINATOR gestionan jóvenes, tribus, proyectos, asistencias y reportes.
- Auditoría básica.
- Rate limiting simple por IP para el endpoint QR.

## Ejecutar
1. Copia `.env.example` a `.env`.
2. Ajusta las variables a tu organización:
   - `APP_NAME`: nombre que muestra la API.
   - `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`: base de datos que crea `docker compose`.
   - `DATABASE_URL`: cadena de conexión que usa la API (debe coincidir con los valores `DB_*`, o apuntar a tu propio PostgreSQL).
   - `JWT_SECRET`, `FIRST_ADMIN_*`: secreto JWT y primer administrador (cámbialos siempre).
3. Ejecuta `docker compose up --build`.
4. Swagger: `http://localhost:8000/docs` (puerto configurable con `API_PORT`).

El esquema SQL de referencia está en `../database/schema.sql`.

El primer administrador se crea automáticamente con las variables `FIRST_ADMIN_*`.

## Endpoints
- POST `/api/auth/login`
- GET `/api/auth/me`
- POST `/api/auth/change-password`
- GET/POST/PUT/DELETE `/api/youth`
- POST `/api/youth/{id}/regenerate-qr`
- GET/POST/PUT/DELETE `/api/tribes`
- GET/POST/PUT/DELETE `/api/projects`
- GET/POST/PUT/DELETE `/api/users` (ADMIN)
- POST `/api/users/{id}/reset-password` (ADMIN)
- POST `/api/attendance/qr` (público)
- POST `/api/attendance/manual` (autenticado)
- GET `/api/attendance/today`
- GET `/api/reports/summary`
- GET `/api/reports/weekly`
- GET `/api/reports/absent`
- GET `/api/reports/by-tribe`

## Producción
Usa HTTPS con Nginx/Caddy/Traefik, no expongas PostgreSQL a Internet, configura backups, restringe CORS y usa un secreto JWT fuerte. Si despliegas varias réplicas, reemplaza el rate limiter en memoria por Redis.


## Menús dinámicos y roles
- Roles: `SUPER_ADMIN` y `COORDINATOR` (se conserva compatibilidad con `ADMIN`).
- Los super administradores ven todos los módulos.
- Los coordinadores reciben únicamente los menús asignados.
- `GET /api/auth/menu` devuelve el menú al iniciar sesión.
- `GET/PUT /api/users/{id}/permissions` permite asignar menús desde otro super administrador.
