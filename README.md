# Northwind DW — Data Warehouse con Arquitectura Medallion en ClickHouse

Proyecto educativo que implementa un Data Warehouse sobre la base de datos Northwind usando la arquitectura Medallion (Bronze / Silver / Gold) con Python y ClickHouse como motor analítico.

---

## Arquitectura

```
PostgreSQL (Northwind)
        │
        ▼
┌──────────────┐
│    BRONZE    │  Copia exacta de la fuente. Sin transformaciones.
│   raw_*      │  + _ingested_at, _source
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    SILVER    │  Datos limpios y validados. Tipos correctos.
│   stg_*      │  Nulos resueltos. Sin modelo dimensional aún.
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     GOLD     │  Star Schema + KPIs precalculados.
│  dim_*       │  dim_* desnormalizadas, fact_sales, agg_*
│  fact_*      │
│  agg_*       │
└──────────────┘
```

### Star Schema (Gold)

```
              dim_date
                 │
dim_customers ───┤
                 │
dim_employees ───┼──── fact_sales ────── dim_products
                 │
dim_shippers  ───┘
```

`fact_sales` tiene granularidad de **línea de pedido** (una fila = un producto dentro de una orden). Incluye un surrogate key generado con `cityHash64(order_id, product_id)`.

---

## Estructura del proyecto

```
EJERCICIO_DW/
├── .gitignore
├── README.md
│
├── data/                          # archivos temporales (csv, parquet)
├── docs/                          # diagramas y documentación
│
├── notebooks/
│   ├── .env                       # credenciales (NO subir a git)
│   ├── sql/
│   │   ├── 01_bronze_ddl.sql      # DDL tablas Bronze
│   │   ├── 02_silver_ddl.sql      # DDL tablas Silver
│   │   └── 03_gold_ddl.sql        # DDL tablas Gold
│   │
│   ├── 00_setup.ipynb             # crea databases y tablas
│   ├── 01_etl_raw_2_bronze.ipynb  # PostgreSQL → Bronze
│   ├── 02_etl_bronze_2_silver.ipynb # Bronze → Silver
│   ├── 03_etl_silver_2_gold.ipynb # Silver → Gold
│   └── 04_pipeline.ipynb          # orquesta todo el flujo
│
└── src/
    ├── config.py                  # conexiones PG y ClickHouse
    ├── utils.py                   # execute_sql_file
    ├── checks.py                  # validaciones por capa
    ├── etl_raw_2_bronze.py        # funciones ETL Bronze
    ├── etl_bronze_2_silver.py     # funciones ETL Silver
    └── etl_silver_2_gold.py       # funciones ETL Gold
```

---

## Requisitos

- Python 3.10+
- PostgreSQL con la base de datos Northwind
- ClickHouse Server

### Instalación de dependencias

```bash
pip install clickhouse-driver psycopg2-binary pandas sqlalchemy python-dotenv
```

---

## Configuración

Crea el archivo `notebooks/.env` basándote en el ejemplo:

```bash
cp notebooks/.env.example notebooks/.env
```

Edita `.env` con tus credenciales:

```env
# PostgreSQL
PG_HOST=localhost
PG_PORT=5432
PG_DATABASE=northwind
PG_USER=tu_usuario
PG_PASSWORD=tu_password

# ClickHouse
CH_HOST=localhost
CH_PORT=9000
CH_USER=default
CH_PASSWORD=

# Capas
BRONZE_DB=bronze
SILVER_DB=silver
GOLD_DB=gold
```

---

## Ejecución

### Opción 1 — Notebook por notebook (recomendado para aprender)

```
00_setup.ipynb             → crea las 3 databases y todas las tablas
01_etl_raw_2_bronze.ipynb  → carga datos desde PostgreSQL
02_etl_bronze_2_silver.ipynb → limpia y transforma
03_etl_silver_2_gold.ipynb → construye el Star Schema y KPIs
```

### Opción 2 — Pipeline completo

```
04_pipeline.ipynb          → ejecuta todo de principio a fin
```

---

## Tablas por capa

### Bronze — copia raw

| Tabla | Descripción |
|-------|-------------|
| `raw_customers` | Clientes |
| `raw_orders` | Órdenes de compra |
| `raw_order_details` | Detalle de cada orden |
| `raw_products` | Productos |
| `raw_categories` | Categorías |
| `raw_suppliers` | Proveedores |
| `raw_employees` | Empleados |
| `raw_shippers` | Transportistas |
| `raw_territories` | Territorios |
| `raw_region` | Regiones |

### Silver — staging limpio

| Tabla | Descripción |
|-------|-------------|
| `stg_customers` | Clientes normalizados |
| `stg_orders` | Órdenes con tipos correctos |
| `stg_order_details` | Detalle sin nulos |
| `stg_products` | Productos limpios |
| `stg_categories` | Categorías |
| `stg_suppliers` | Proveedores |
| `stg_employees` | Empleados con `full_name` calculado |
| `stg_shippers` | Transportistas |
| `stg_territories` | Territorios |
| `stg_region` | Regiones |

### Gold — Star Schema + KPIs

| Tabla | Tipo | Descripción |
|-------|------|-------------|
| `dim_customers` | Dimensión | Clientes |
| `dim_products` | Dimensión | Productos desnormalizados con categoría y proveedor |
| `dim_employees` | Dimensión | Empleados |
| `dim_shippers` | Dimensión | Transportistas |
| `dim_territories` | Dimensión | Territorios con región |
| `dim_date` | Dimensión | Calendario 1990–2030 |
| `fact_sales` | Hecho | Líneas de pedido con surrogate key |
| `agg_sales_monthly` | Agregación | Ventas por mes y país |
| `agg_product_performance` | Agregación | Performance de productos |
| `agg_customer_rfm` | Agregación | RFM de clientes |
| `agg_employee_kpis` | Agregación | KPIs de empleados |

---

## Decisiones de diseño

**¿Por qué dos capas antes del Star Schema?**
Bronze garantiza que siempre tienes una copia fiel de la fuente. Silver te da datos confiables para construir el modelo. Si algo falla en Gold, reprocessas desde Silver sin tocar la fuente.

**¿Por qué ClickHouse?**
Motor columnar open source optimizado para queries analíticas. Lee millones de filas por segundo y comprime muy bien datos repetitivos como los de un DW.

**¿Por qué una sola `fact_sales`?**
`orders` y `order_details` se desnormalizan en una sola tabla con granularidad de línea de pedido. Simplifica los JOINs y es suficiente para todos los KPIs del negocio.

**`sale_price` vs `list_price`**
`dim_products.list_price` es el precio de catálogo actual. `fact_sales.sale_price` es el precio real al que se vendió. Esto permite analizar descuentos respecto al catálogo.

**ClickHouse no tiene Foreign Keys**
La integridad referencial es responsabilidad del pipeline. Por eso las dimensiones se cargan siempre antes que `fact_sales` y los checks validan huérfanos después de cada carga.

---

## Validaciones

Cada capa tiene sus propios checks:

```python
from checks import check_bronze, check_silver, check_gold
from config import CH

check_bronze(CH)   # nulos en PK, duplicados, conteos
check_silver(CH)   # tipos, rangos, valores vacíos
check_gold(CH)     # huérfanos en fact, integridad del Star Schema
```

---

## Motores ClickHouse por capa

| Capa | Motor | Por qué |
|------|-------|---------|
| Bronze | `MergeTree` | Solo append, no hay re-cargas |
| Silver | `ReplacingMergeTree` | Re-ejecutable sin duplicados |
| Gold dims | `ReplacingMergeTree` | Se reconstruyen completas cada vez |
| Gold facts | `MergeTree` + PARTITION | Eventos, particionados por mes |
| Gold aggs | `ReplacingMergeTree` | Se recalculan en cada ejecución |

> Al consultar tablas `ReplacingMergeTree` usa `FINAL` para garantizar resultados deduplicados:
> ```sql
> SELECT * FROM gold.dim_customers FINAL;
> ```

## .env
La configuración de conexión del sistema fuente se encuentra definida en el archivo .env. Recuerde completar el host y la contraseña de su sistema destino antes de ejecutar el pipeline.



