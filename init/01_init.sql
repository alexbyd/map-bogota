-- =============================================================================
-- 01_init.sql  —  PostGIS setup para Bogotá Arriendos
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS hstore;

-- =============================================================================
-- Tabla principal: arriendos
-- =============================================================================
CREATE TABLE IF NOT EXISTS casas (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(200)  NOT NULL,
    descripcion TEXT          DEFAULT '',
    ubicacion   GEOGRAPHY(POINT, 4326) NOT NULL,
    tipo        VARCHAR(30)   DEFAULT 'casa'
                              CHECK (tipo IN ('apartamento','habitacion','apartaestudio','casa')),
    telefono    VARCHAR(30)   DEFAULT '',
    fotos       JSONB         DEFAULT '[]'::jsonb,   -- array de data-URIs base64
    creado_en   TIMESTAMPTZ   DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_casas_ubicacion
    ON casas USING GIST(ubicacion);

CREATE INDEX IF NOT EXISTS idx_casas_tipo
    ON casas (tipo);

-- Datos de ejemplo
INSERT INTO casas (nombre, descripcion, ubicacion, tipo, telefono, fotos) VALUES
    ('Apartamento Chapinero',  'Cerca al parque, 2 hab',  ST_SetSRID(ST_MakePoint(-74.0621, 4.6486), 4326)::geography, 'apartamento',   '3001234567', '[]'),
    ('Casa Usaquén',           'Barrio tranquilo, 3 hab', ST_SetSRID(ST_MakePoint(-74.0317, 4.6942), 4326)::geography, 'casa',          '3109876543', '[]'),
    ('Habitación Kennedy',     'Zona residencial',        ST_SetSRID(ST_MakePoint(-74.1469, 4.6281), 4326)::geography, 'habitacion',    '3205551234', '[]'),
    ('Apartaestudio La Candelaria', 'Centro histórico',   ST_SetSRID(ST_MakePoint(-74.0750, 4.5980), 4326)::geography, 'apartaestudio', '3154445566', '[]');
