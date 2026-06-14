# Bogotá Arriendos 🏠

**Stack:** FastAPI · PostGIS · Martin (vector tiles) · OSRM (rutas) · MapLibre GL · WebSockets

---
## Estructura del proyecto
```
bogota-map/
├── app/
│   ├── main.py              # FastAPI backend
│   ├── map_generator.py     # Genera el HTML del mapa con MapLibre
│   ├── templates/
│   │   └── index.html       # Plantilla base (solo inyecta map_html)
│   └── static/libs/         # MapLibre GL (generado por script 03)
├── init/
│   ├── 01_init.sql          # Crea extensiones + tabla casas
│   └── 02_crear_vistas.sql  # Vistas para Martin (post-osm2pgsql)
├── martin/
│   └── config.yaml          # Configuración del tile server
├── scripts/
│   ├── 01_preparar_datos.sh # Descarga OSM, recorta Bogotá, carga PostGIS
│   ├── 02_preparar_osrm.sh  # Preprocesa datos de routing (driving + walking)
│   ├── 03_descargar_assets.sh # Descarga MapLibre para uso offline
│   └── 04_deploy_produccion.sh # Guía de deploy en servidor
├── data/                    # Archivos OSM y OSRM (generados por scripts)
├── Dockerfile
├── docker-compose.yml
└── requirements.txt
```


## limpiar los volúmenes y empezar completamente fresco:
docker compose down -v && docker compose up -d

## Eliminar el contenedor específico que causa conflicto
docker rm -f bogota_db

## También eliminar los otros si existen
docker rm -f bogota_osrm_foot bogota_osrm_car

## Luego levantar todo
docker compose up -d

## Detener y eliminar contenedores, redes y volúmenes definidos en el compose
docker compose down -v

## Luego levantar de nuevo
docker compose up -d

## Detener todos los contenedores en ejecución
docker stop $(docker ps -aq)

## Eliminar todos los contenedores
docker rm $(docker ps -aq)

## (Opcional) Eliminar volúmenes no utilizados
docker volume prune -f

## Luego levantar tu proyecto
docker compose up -d


---

## Setup inicial (primera vez)

### 1. Prerequisitos
- Docker Desktop (Mac/Windows) o Docker Engine (Linux)
- `osmium-tool`: `brew install osmium-tool` (Mac) / `sudo apt install osmium-tool` (Linux)

### 2. Descargar assets de MapLibre
```bash
bash scripts/03_descargar_assets.sh
```

### 3. Preparar datos OSM (~10 min)
```bash
bash scripts/01_preparar_datos.sh
```
Descarga ~60 MB de Colombia, recorta Bogotá y carga en PostGIS.

### 4. Preparar datos de routing (~5-15 min según CPU)
```bash
bash scripts/02_preparar_osrm.sh
```
Genera los índices de OSRM para rutas en vehículo y a pie.

### 5. Levantar todo
```bash
docker compose up -d
```

### 6. Abrir la app
[http://localhost:8000](http://localhost:8000)

---

## Uso diario (ya con datos preparados)

```bash
docker compose up -d      # levantar
docker compose down       # detener
docker compose logs -f app  # ver logs
```

---

## Características

- **Mapa limpio** — solo el mapa, sin barras ni botones de zoom
- **Botón +** — abre formulario para publicar un arriendo
- **Formulario**
  - Tipo: Apartamento / Habitación / Apartaestudio / Casa
  - Número de contacto del arrendador
  - Hasta 4 fotos (comprimidas automáticamente a 800px)
  - Ubicación automática por GPS al abrir el formulario
- **Rutas** — cálculo offline con OSRM (vehículo y caminata)
- **Tiempo real** — WebSockets: los nuevos arriendos aparecen en todos los clientes abiertos

---

## Producción

Ver `scripts/04_deploy_produccion.sh` y ajustar en `docker-compose.yml`:
```yaml
MARTIN_PUBLIC: http://TU_IP_O_DOMINIO:3000
```
`MARTIN_PUBLIC` lo usa el **browser** para pedir los tiles, por lo que debe ser la IP/dominio público accesible desde el cliente.
