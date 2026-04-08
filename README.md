# 🎬 Data Mart Sakila — Arquitectura Medallion

> **Proyecto Final Fase I** | Diseño & Construcción de Data Warehouse  
> Universidad Galileo — Postgrado en Análisis y Predicción de Datos | Abril 2026

---

## 👥 Integrantes

| Nombre | Carnet |
|--------|--------|
| Robinson René López Hidalgo | 26007448 |
| Mynor Geovanny Mendoza Ordóñez | 26008754 |

---

## 📋 Descripción del Proyecto

Implementación de un **Data Mart completo** para la base de datos **Sakila**, que simula el sistema transaccional de una empresa de alquiler de películas. El proyecto utiliza la **Arquitectura Medallion** (Bronze / Silver / Gold) con **ClickHouse** como motor analítico y **MySQL en AWS RDS** como fuente de datos OLTP.

---

## 🏗️ Arquitectura de la Solución

```
┌─────────────────────────────────────────────┐
│         FUENTE DE DATOS (OLTP)              │
│   MySQL 8.4.7 — AWS RDS — Base: Sakila      │
│   16 tablas: rental, film, customer,        │
│   payment, inventory, actor, store...       │
└───────────────────┬─────────────────────────┘
                    │  ETL con Python + pandas
                    ▼
┌─────────────────────────────────────────────┐
│           CAPA BRONZE — ClickHouse          │
│   Copia exacta de MySQL. Sin transformar.   │
│   15 tablas raw_* con auditoría:            │
│   _ingested_at | _source = 'mysql'          │
│   Motor: MergeTree                          │
└───────────────────┬─────────────────────────┘
                    │  trimBoth, ifNull, concat
                    ▼
┌─────────────────────────────────────────────┐
│           CAPA SILVER — ClickHouse          │
│   Datos limpios y estandarizados.           │
│   15 tablas stg_* con _processed_at         │
│   full_name generado, nulos eliminados      │
│   Motor: ReplacingMergeTree                 │
└───────────────────┬─────────────────────────┘
                    │  JOINs, dim_date con pandas
                    ▼
┌─────────────────────────────────────────────┐
│            CAPA GOLD — ClickHouse           │
│         ESQUEMA ESTRELLA (Star Schema)      │
│                                             │
│   dim_film      dim_customer   dim_staff    │
│        \             |            /         │
│         └────── fact_rental ─────┘          │
│        /             |            \         │
│   dim_store     dim_date      dim_actor     │
│                                             │
│   fact_rental: 16,044 hechos               │
│   Motor: MergeTree + PARTITION BY mes       │
└─────────────────────────────────────────────┘
                    │
                    ▼
         Power BI Desktop (Fase II)
         Conectado via ODBC a Gold
```

---

## 🛠️ Tecnologías Utilizadas

| Componente | Tecnología |
|------------|------------|
| Base de datos fuente | MySQL 8.4.7 en AWS RDS |
| Motor analítico | ClickHouse 26.3 en AWS EC2 (Ubuntu 24.04) |
| IP del servidor | Elastic IP: 16.59.133.181 |
| Pipeline ETL | Python 3.11 + Jupyter Notebooks |
| Manipulación de datos | pandas |
| Conexión a ClickHouse | clickhouse-driver |
| Conexión a MySQL | SQLAlchemy + PyMySQL |
| Cliente SQL | DBeaver Community |
| SSH al servidor | Termius |
| Visualización | Power BI Desktop |
| Región AWS | us-east-2 (Ohio) |

---

## 📁 Estructura del Repositorio

```
datamart-sakila-medallion/
├── notebooks/
│   ├── 00_setup.ipynb              ← Crea las 36 tablas en ClickHouse
│   ├── 01_etl_raw_2_bronze.ipynb   ← MySQL → Bronze (15 tablas raw_*)
│   ├── 02_etl_bronze_2_silver.ipynb ← Bronze → Silver (limpieza)
│   ├── 03_etl_silver_2_gold.ipynb  ← Silver → Gold (Star Schema)
│   ├── 04_quality_check.ipynb      ← Validaciones de calidad
│   └── 05_analisis.ipynb           ← Consultas analíticas + gráfico
├── sql/
│   ├── bronze_ddl.sql              ← DDL 15 tablas raw_*
│   ├── silver_ddl.sql              ← DDL 15 tablas stg_*
│   └── gold_ddl.sql                ← DDL 6 dims + fact_rental
├── src/
│   ├── config.py                   ← Conexiones MySQL + ClickHouse
│   └── utils.py                    ← execute_sql_file()
├── outputs/
│   └── serie_temporal_sakila.png   ← Gráfico serie temporal
├── .env.example                    ← Plantilla de credenciales
├── .gitignore
├── requirements.txt
└── README.md
```

---

## ⚙️ Instalación y Configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/robinsonlopez-galileo/datamart-sakila-medallion.git
cd datamart-sakila-medallion
```

### 2. Crear el entorno Python

```bash
# Con Conda (recomendado)
conda create -n northwind python=3.11 -y
conda activate northwind

# O con venv
python -m venv venv
venv\Scripts\activate   # Windows
```

### 3. Instalar dependencias

```bash
pip install -r requirements.txt
```

### 4. Configurar credenciales

```bash
# Copiar la plantilla
cp .env.example src/.env

# Editar src/.env con sus credenciales reales
```

Contenido del archivo `src/.env`:

```env
# MySQL (AWS RDS)
PG_HOST=your-rds-endpoint.rds.amazonaws.com
PG_PORT=3306
PG_DATABASE=sakila
PG_USER=admin
PG_PASSWORD=your_password

# ClickHouse (AWS EC2)
CH_HOST=your-ec2-ip
CH_PORT=9000
CH_USER=ch_user
CH_PASSWORD=your_password

# Capas
BRONZE_DB=bronze
SILVER_DB=silver
GOLD_DB=gold

# Pipeline
LOG_LEVEL=INFO
BATCH_SIZE=50000
```

---

## ▶️ Orden de Ejecución

Abrir Jupyter Lab desde la carpeta del proyecto y ejecutar los notebooks en este orden:

| Orden | Notebook | Función | Resultado |
|-------|----------|---------|-----------|
| 1 | `00_setup.ipynb` | Crea las tablas en ClickHouse | 36 tablas (15+15+6) |
| 2 | `01_etl_raw_2_bronze.ipynb` | MySQL → Bronze | 16,044 rentas cargadas |
| 3 | `02_etl_bronze_2_silver.ipynb` | Bronze → Silver | Datos limpios |
| 4 | `03_etl_silver_2_gold.ipynb` | Silver → Gold | Star Schema completo |
| 5 | `04_quality_check.ipynb` | Validaciones | Todos los checks ✓ |
| 6 | `05_analisis.ipynb` | Consultas + gráfico | 5 preguntas analíticas |

```bash
# Abrir Jupyter Lab
jupyter lab
```

---

## 📊 Resultados del Pipeline

### Conteos por capa

| Tabla | Bronze | Silver | Gold |
|-------|--------|--------|------|
| rental / fact_rental | 16,044 | 16,044 | 16,044 |
| film / dim_film | 1,000 | 1,000 | 1,000 |
| customer / dim_customer | 599 | 599 | 599 |
| actor / dim_actor | 200 | 200 | 200 |
| address | 603 | 603 | — |
| inventory | 4,581 | 4,581 | — |
| film_actor | 5,462 | 5,462 | — |
| dim_date | — | — | 1,095 |

### Quality Check — Resultados

| Validación | Resultado |
|------------|-----------|
| PKs nulas en tablas principales | ✅ 0 errores |
| Duplicados en dimensiones | ✅ 0 duplicados |
| Clientes sin país en Gold | ✅ 0 errores |
| Registros huérfanos en fact_rental | ✅ 0 huérfanos |
| Montos negativos en pagos | ✅ 0 errores |
| dim_date sin duplicados | ✅ 0 duplicados |

---

## 🔍 Consultas Analíticas (Fase I)

El notebook `05_analisis.ipynb` responde las siguientes preguntas de negocio:

1. **Top 10 películas más rentadas** — Bucket Brotherhood (34), Rocketeer Mother (33)
2. **País con más rentas** — Distribución geográfica de 109 países
3. **Montos totales por cliente** — Ranking de los 599 clientes
4. **Actor con más rentas** — Cruce fact_rental + film_actor + dim_actor
5. **Serie temporal de ingresos** — Gráfico mensual 2005–2007

---

## 📈 Fase II — Tablero Power BI (En construcción)

Power BI Desktop conectado directamente a la capa Gold de ClickHouse mediante ODBC.

**Visualizaciones planificadas:**
- 📊 Top 10 películas más rentadas (barras)
- 🗺️ Mapa de rentas por país
- 📈 Serie temporal de ingresos mensuales
- 👥 Ranking de clientes por monto
- 🎭 Top actores por rentas generadas
- 🃏 KPIs: Total Rentas | Ingresos | Clientes | Películas

---

## 🎥 Video de Presentación

[▶️ Ver presentación en YouTube](https://www.youtube.com/watch?v=XlhqRh6DHqU)

---

## 📄 Documentación

La documentación formal del proyecto en formato APA 7 está disponible en el repositorio del curso en el GES de Universidad Galileo.

---

## 📝 Notas Técnicas

- El archivo `.env` **no está versionado** por seguridad. Use `.env.example` como plantilla.
- Las instancias AWS (RDS + EC2) están activas y accesibles para evaluación.
- El pipeline es **re-ejecutable**: cada notebook hace TRUNCATE antes de insertar.
- La tabla `address` de Sakila requirió un script especial por incompatibilidad del tipo GEOMETRY con MySQL 8.4.7 en RDS.

---

*Robinson René López Hidalgo & Mynor Geovanny Mendoza Ordóñez — Universidad Galileo 2026*
