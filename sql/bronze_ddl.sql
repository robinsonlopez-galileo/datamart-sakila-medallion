-- ══════════════════════════════════════════════════════════════════
-- BRONZE — Capa de Ingesta Raw
-- Proyecto: Data Mart Sakila
-- Motor: ClickHouse
-- Descripción: Copia exacta de MySQL RDS + columnas de auditoría
--              Sin transformaciones. Datos tal como vienen de la fuente.
-- ══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS bronze.raw_actor (
    actor_id     UInt16,
    first_name   String,
    last_name    String,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY actor_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_address (
    address_id   UInt16,
    address      String,
    address2     Nullable(String),
    district     String,
    city_id      UInt16,
    postal_code  Nullable(String),
    phone        String,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY address_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_category (
    category_id  UInt8,
    name         String,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY category_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_city (
    city_id      UInt16,
    city         String,
    country_id   UInt16,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY city_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_country (
    country_id   UInt16,
    country      String,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY country_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_customer (
    customer_id  UInt16,
    store_id     UInt8,
    first_name   String,
    last_name    String,
    email        Nullable(String),
    address_id   UInt16,
    active       UInt8,
    create_date  DateTime,
    last_update  Nullable(DateTime),
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY customer_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_film (
    film_id              UInt16,
    title                String,
    description          Nullable(String),
    release_year         Nullable(UInt16),
    language_id          UInt8,
    original_language_id Nullable(UInt8),
    rental_duration      UInt8,
    rental_rate          Decimal(4,2),
    length               Nullable(UInt16),
    replacement_cost     Decimal(5,2),
    rating               Nullable(String),
    special_features     Nullable(String),
    last_update          DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY film_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_film_actor (
    actor_id     UInt16,
    film_id      UInt16,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY (actor_id, film_id);

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_film_category (
    film_id      UInt16,
    category_id  UInt8,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY (film_id, category_id);

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_inventory (
    inventory_id UInt32,
    film_id      UInt16,
    store_id     UInt8,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY inventory_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_language (
    language_id  UInt8,
    name         String,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY language_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_payment (
    payment_id   UInt16,
    customer_id  UInt16,
    staff_id     UInt8,
    rental_id    Nullable(Int32),
    amount       Decimal(5,2),
    payment_date DateTime,
    last_update  Nullable(DateTime),
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY payment_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_rental (
    rental_id    Int32,
    rental_date  DateTime,
    inventory_id UInt32,
    customer_id  UInt16,
    return_date  Nullable(DateTime),
    staff_id     UInt8,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY rental_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_staff (
    staff_id     UInt8,
    first_name   String,
    last_name    String,
    address_id   UInt16,
    email        Nullable(String),
    store_id     UInt8,
    active       UInt8,
    username     String,
    last_update  DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY staff_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_store (
    store_id         UInt8,
    manager_staff_id UInt8,
    address_id       UInt16,
    last_update      DateTime,
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'mysql'
) ENGINE = MergeTree()
ORDER BY store_id;
