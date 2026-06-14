-- =============================================================================
-- 02_crear_vistas.sql — Vistas para Martin tile server
-- Ejecutar DESPUÉS de cargar bogota.osm.pbf con osm2pgsql
-- =============================================================================

-- ── Calles ────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW bogota_calles AS
SELECT
    osm_id,
    highway,
    name,
    way AS geom
FROM planet_osm_line
WHERE highway IS NOT NULL
  AND highway NOT IN ('footway','path','cycleway','steps','platform');

-- ── Edificios ─────────────────────────────────────────────────────────────────
-- FIX: eliminada definición duplicada que existía en el archivo original
CREATE OR REPLACE VIEW bogota_edificios AS
SELECT
    osm_id,
    building,
    name,
    way AS geom
FROM planet_osm_polygon
WHERE building IS NOT NULL;

-- ── Parques ───────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW bogota_parques AS
SELECT
    osm_id,
    COALESCE(leisure, landuse) AS tipo,
    name,
    way AS geom
FROM planet_osm_polygon
WHERE leisure IN ('park','garden','pitch','playground')
   OR landuse  IN ('grass','forest','recreation_ground');

-- ── Agua ──────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW bogota_agua AS
SELECT osm_id, waterway, name, way AS geom
FROM planet_osm_line
WHERE waterway IS NOT NULL
UNION ALL
SELECT osm_id, 'area' AS waterway, name, way AS geom
FROM planet_osm_polygon
WHERE water IS NOT NULL OR waterway IS NOT NULL;

-- ── Arriendos (pines) ─────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW bogota_casas_view AS
SELECT id, nombre, tipo, telefono, descripcion, creado_en,
       ubicacion::geometry AS geom
FROM casas;

-- ── Índices de soporte ────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_osm_line_highway
    ON planet_osm_line USING GIST(way)
    WHERE highway IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_osm_polygon_building
    ON planet_osm_polygon USING GIST(way)
    WHERE building IS NOT NULL;

SELECT 'Vistas para Martin creadas correctamente.' AS status;
