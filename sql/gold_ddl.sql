-- ══════════════════════════════════════════════════════════════════
-- GOLD — Capa de Esquema Estrella (Star Schema)
-- Proyecto: Data Mart Sakila
-- Motor: ClickHouse
-- Descripción: Dimensiones desnormalizadas + tabla de hechos.
--              Optimizado para consultas analíticas de negocio.
-- ══════════════════════════════════════════════════════════════════

-- ── DIMENSIÓN PELÍCULA ─────────────────────────────────────────────
-- Contiene información completa de cada película incluyendo
-- categoría e idioma resueltos desde Silver.
CREATE TABLE IF NOT EXISTS gold.dim_film (
    film_key         UInt16,
    title            String,
    description      String,
    release_year     UInt16,
    language         String,
    category         String,
    rating           String,
    rental_duration  UInt8,
    rental_rate      Decimal(4,2),
    length_minutes   UInt16,
    replacement_cost Decimal(5,2),
    _valid_from      DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_valid_from)
ORDER BY film_key;

-- ── DIMENSIÓN CLIENTE ──────────────────────────────────────────────
-- Contiene información del cliente con ciudad y país resueltos
-- mediante JOIN con address, city y country desde Silver.
CREATE TABLE IF NOT EXISTS gold.dim_customer (
    customer_key  UInt16,
    full_name     String,
    email         String,
    address       String,
    district      String,
    city          String,
    country       String,
    postal_code   String,
    active        UInt8,
    store_id      UInt8,
    _valid_from   DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_valid_from)
ORDER BY customer_key;

-- ── DIMENSIÓN EMPLEADO ─────────────────────────────────────────────
-- Personal que procesó las rentas.
CREATE TABLE IF NOT EXISTS gold.dim_staff (
    staff_key   UInt8,
    full_name   String,
    email       String,
    store_id    UInt8,
    username    String,
    active      UInt8,
    _valid_from DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_valid_from)
ORDER BY staff_key;

-- ── DIMENSIÓN TIENDA ───────────────────────────────────────────────
-- Tiendas físicas con su ubicación y gerente resueltos.
CREATE TABLE IF NOT EXISTS gold.dim_store (
    store_key    UInt8,
    manager_name String,
    address      String,
    city         String,
    country      String,
    _valid_from  DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_valid_from)
ORDER BY store_key;

-- ── DIMENSIÓN ACTOR ────────────────────────────────────────────────
-- Actores de las películas disponibles en el catálogo.
CREATE TABLE IF NOT EXISTS gold.dim_actor (
    actor_key   UInt16,
    full_name   String,
    _valid_from DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_valid_from)
ORDER BY actor_key;

-- ── DIMENSIÓN FECHA ────────────────────────────────────────────────
-- Calendario generado con Python (pandas.date_range).
-- Rango: 2005-01-01 a 2007-12-31 (rango de datos de Sakila).
CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_key     Int32,
    full_date    Date,
    year         Int32,
    quarter      Int32,
    quarter_name String,
    month        Int32,
    month_name   String,
    week         Int32,
    day          Int32,
    day_name     String,
    is_weekend   Int8
) ENGINE = MergeTree()
ORDER BY date_key;

-- ══════════════════════════════════════════════════════════════════
-- TABLA DE HECHOS — fact_rental
-- Granularidad: una fila por renta
-- Métricas: amount (monto pagado), rental_duration_days
-- Llaves foráneas: film_key, customer_key, staff_key,
--                  store_key, date_key, inventory_id
-- ══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS gold.fact_rental (
    rental_id            Int32,
    date_key             Int32,        -- FK → dim_date
    film_key             UInt16,       -- FK → dim_film
    customer_key         UInt16,       -- FK → dim_customer
    staff_key            UInt8,        -- FK → dim_staff
    store_key            UInt8,        -- FK → dim_store
    inventory_id         UInt32,
    amount               Decimal(5,2), -- monto pagado por la renta
    rental_duration_days Int32,        -- días que duró la renta
    rental_date          DateTime,
    return_date          Nullable(DateTime),
    payment_date         Nullable(DateTime)
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(rental_date)
ORDER BY (date_key, customer_key, film_key, rental_id);
