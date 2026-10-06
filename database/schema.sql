-- Community Attendance - Registro y control de asistencia
-- PostgreSQL 15+
-- Diseñado para: jóvenes, tribus, proyectos/equipos, usuarios coordinadores/admin y asistencias.
-- No almacena cédula ni datos sensibles innecesarios.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =========================
-- 1. Usuarios del sistema
-- =========================
CREATE TABLE app_user (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name           VARCHAR(120) NOT NULL,
    username            VARCHAR(60) NOT NULL UNIQUE,
    password_hash       TEXT NOT NULL,
    role                VARCHAR(20) NOT NULL
                        CHECK (role IN ('ADMIN', 'COORDINATOR')),
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================
-- 2. Tribus
-- =========================
CREATE TABLE tribe (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(250),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================
-- 3. Proyectos / equipos
-- =========================
CREATE TABLE project (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tribe_id    UUID NULL REFERENCES tribe(id) ON DELETE SET NULL,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(250),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tribe_id, name)
);

-- =========================
-- 4. Jóvenes
-- =========================
CREATE TABLE youth (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name       VARCHAR(120) NOT NULL,
    phone           VARCHAR(25) NOT NULL,
    tribe_id        UUID NOT NULL REFERENCES tribe(id) ON DELETE RESTRICT,
    project_id      UUID NULL REFERENCES project(id) ON DELETE SET NULL,

    -- El QR debe contener SOLO este token opaco, nunca nombre/teléfono.
    qr_token        UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),

    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      UUID NULL REFERENCES app_user(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_youth_name ON youth (full_name);
CREATE INDEX idx_youth_phone ON youth (phone);
CREATE INDEX idx_youth_tribe ON youth (tribe_id);
CREATE INDEX idx_youth_project ON youth (project_id);
CREATE INDEX idx_youth_active ON youth (is_active);

-- =========================
-- 5. Asistencias
-- =========================
CREATE TABLE attendance (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    youth_id        UUID NOT NULL REFERENCES youth(id) ON DELETE RESTRICT,
    attendance_date DATE NOT NULL DEFAULT CURRENT_DATE,
    registered_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    source           VARCHAR(10) NOT NULL
                     CHECK (source IN ('QR', 'MANUAL')),

    registered_by   UUID NULL REFERENCES app_user(id) ON DELETE SET NULL,
    notes           VARCHAR(250),

    -- Evita registrar dos veces al mismo joven el mismo día.
    UNIQUE (youth_id, attendance_date)
);

CREATE INDEX idx_attendance_date ON attendance (attendance_date);
CREATE INDEX idx_attendance_youth ON attendance (youth_id);

-- =========================
-- 6. Auditoría mínima
-- =========================
CREATE TABLE audit_log (
    id            BIGSERIAL PRIMARY KEY,
    user_id       UUID NULL REFERENCES app_user(id) ON DELETE SET NULL,
    action        VARCHAR(50) NOT NULL,
    entity_type   VARCHAR(50) NOT NULL,
    entity_id     UUID NULL,
    details       JSONB,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_created_at ON audit_log (created_at DESC);
CREATE INDEX idx_audit_user ON audit_log (user_id);

-- =========================
-- 7. Vista para reportes semanales
-- =========================
CREATE OR REPLACE VIEW vw_weekly_attendance AS
SELECT
    date_trunc('week', a.attendance_date)::date AS week_start,
    y.id AS youth_id,
    y.full_name,
    y.phone,
    t.id AS tribe_id,
    t.name AS tribe_name,
    p.id AS project_id,
    p.name AS project_name,
    COUNT(*) AS attendance_count
FROM attendance a
JOIN youth y ON y.id = a.youth_id
JOIN tribe t ON t.id = y.tribe_id
LEFT JOIN project p ON p.id = y.project_id
GROUP BY
    date_trunc('week', a.attendance_date)::date,
    y.id,
    y.full_name,
    y.phone,
    t.id,
    t.name,
    p.id,
    p.name;

-- =========================
-- 8. Ejemplos de consultas
-- =========================

-- Jóvenes que asistieron esta semana:
-- SELECT * FROM vw_weekly_attendance
-- WHERE week_start = date_trunc('week', CURRENT_DATE)::date
-- ORDER BY attendance_count DESC, full_name;

-- Total de asistencias por tribu esta semana:
-- SELECT t.name, COUNT(*) AS total_asistencias
-- FROM attendance a
-- JOIN youth y ON y.id = a.youth_id
-- JOIN tribe t ON t.id = y.tribe_id
-- WHERE a.attendance_date >= date_trunc('week', CURRENT_DATE)::date
--   AND a.attendance_date <  date_trunc('week', CURRENT_DATE)::date + 7
-- GROUP BY t.name
-- ORDER BY total_asistencias DESC;

-- Jóvenes que NO han asistido esta semana:
-- SELECT y.id, y.full_name, t.name AS tribe_name
-- FROM youth y
-- JOIN tribe t ON t.id = y.tribe_id
-- WHERE y.is_active = TRUE
--   AND NOT EXISTS (
--       SELECT 1
--       FROM attendance a
--       WHERE a.youth_id = y.id
--         AND a.attendance_date >= date_trunc('week', CURRENT_DATE)::date
--         AND a.attendance_date <  date_trunc('week', CURRENT_DATE)::date + 7
--   )
-- ORDER BY t.name, y.full_name;
