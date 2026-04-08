-- ══════════════════════════════════════════════════════════════════
-- SILVER — Capa de Staging Curado
-- Proyecto: Data Mart Sakila
-- Motor: ClickHouse
-- Descripción: Datos limpios y estandarizados desde Bronze.
--              Nulos eliminados, tipos correctos, full_name generado.
-- ══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS silver.stg_actor (
    actor_id      UInt16,
    first_name    String,
    last_name     String,
    full_name     String,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY actor_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_address (
    address_id    UInt16,
    address       String,
    address2      String,
    district      String,
    city_id       UInt16,
    postal_code   String,
    phone         String,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY address_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_category (
    category_id   UInt8,
    name          String,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY category_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_city (
    city_id       UInt16,
    city          String,
    country_id    UInt16,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY city_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_country (
    country_id    UInt16,
    country       String,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY country_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_customer (
    customer_id   UInt16,
    store_id      UInt8,
    first_name    String,
    last_name     String,
    full_name     String,
    email         String,
    address_id    UInt16,
    active        UInt8,
    create_date   DateTime,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY customer_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_film (
    film_id          UInt16,
    title            String,
    description      String,
    release_year     UInt16,
    language_id      UInt8,
    rental_duration  UInt8,
    rental_rate      Decimal(4,2),
    length           UInt16,
    replacement_cost Decimal(5,2),
    rating           String,
    special_features String,
    _processed_at    DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY film_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_film_actor (
    actor_id      UInt16,
    film_id       UInt16,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY (actor_id, film_id);

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_film_category (
    film_id       UInt16,
    category_id   UInt8,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY (film_id, category_id);

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_inventory (
    inventory_id  UInt32,
    film_id       UInt16,
    store_id      UInt8,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY inventory_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_language (
    language_id   UInt8,
    name          String,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY language_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_payment (
    payment_id    UInt16,
    customer_id   UInt16,
    staff_id      UInt8,
    rental_id     Int32,
    amount        Decimal(5,2),
    payment_date  DateTime,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY payment_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_rental (
    rental_id     Int32,
    rental_date   DateTime,
    inventory_id  UInt32,
    customer_id   UInt16,
    return_date   Nullable(DateTime),
    staff_id      UInt8,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY rental_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_staff (
    staff_id      UInt8,
    first_name    String,
    last_name     String,
    full_name     String,
    email         String,
    store_id      UInt8,
    active        UInt8,
    username      String,
    _processed_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY staff_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_store (
    store_id         UInt8,
    manager_staff_id UInt8,
    address_id       UInt16,
    _processed_at    DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY store_id;
