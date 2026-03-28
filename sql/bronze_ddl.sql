-- ══════════════════════════════════════════════
-- BRONZE — Todas las tablas raw
-- Copia exacta de PostgreSQL + auditoría
-- ══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS bronze.raw_customers (
    customer_id   String,
    company_name  String,
    contact_name  Nullable(String),
    contact_title Nullable(String),
    address       Nullable(String),
    city          Nullable(String),
    region        Nullable(String),
    postal_code   Nullable(String),
    country       Nullable(String),
    phone         Nullable(String),
    fax           Nullable(String),
    _ingested_at  DateTime DEFAULT now(),
    _source       String   DEFAULT 'postgresql'
)
ENGINE = MergeTree()
ORDER BY customer_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_orders (
    order_id         Int32,
    customer_id      Nullable(String),
    employee_id      Nullable(Int32),
    order_date       Nullable(Date),
    required_date    Nullable(Date),
    shipped_date     Nullable(Date),
    ship_via         Nullable(Int32),
    freight          Nullable(Float64),
    ship_name        Nullable(String),
    ship_address     Nullable(String),
    ship_city        Nullable(String),
    ship_region      Nullable(String),
    ship_postal_code Nullable(String),
    ship_country     Nullable(String),
    _ingested_at     DateTime DEFAULT now(),
    _source          String   DEFAULT 'postgresql'
)
ENGINE = MergeTree()
ORDER BY order_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_order_details (
    order_id     Int32,
    product_id   Int32,
    unit_price   Nullable(Float64),
    quantity     Nullable(Int32),
    discount     Nullable(Float64),
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'postgresql'
)
ENGINE = MergeTree()
ORDER BY (order_id, product_id);

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_products (
    product_id        Int32,
    product_name      Nullable(String),
    supplier_id       Nullable(Int32),
    category_id       Nullable(Int32),
    quantity_per_unit Nullable(String),
    unit_price        Nullable(Float64),
    units_in_stock    Nullable(Int32),
    units_on_order    Nullable(Int32),
    reorder_level     Nullable(Int32),
    discontinued      Nullable(Int32),
    _ingested_at      DateTime DEFAULT now(),
    _source           String   DEFAULT 'postgresql'
)
ENGINE = MergeTree()
ORDER BY product_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_categories (
    category_id   Int32,
    category_name Nullable(String),
    description   Nullable(String),
    _ingested_at  DateTime DEFAULT now(),
    _source       String   DEFAULT 'postgresql'
)
ENGINE = MergeTree()
ORDER BY category_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_suppliers (
    supplier_id   Int32,
    company_name  Nullable(String),
    contact_name  Nullable(String),
    contact_title Nullable(String),
    address       Nullable(String),
    city          Nullable(String),
    region        Nullable(String),
    postal_code   Nullable(String),
    country       Nullable(String),
    phone         Nullable(String),
    fax           Nullable(String),
    homepage      Nullable(String),
    _ingested_at  DateTime DEFAULT now(),
    _source       String   DEFAULT 'postgresql'
)
ENGINE = MergeTree()
ORDER BY supplier_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_employees (
    employee_id       Int32,
    last_name         Nullable(String),
    first_name        Nullable(String),
    title             Nullable(String),
    title_of_courtesy Nullable(String),
    birth_date        Nullable(Date),
    hire_date         Nullable(Date),
    address           Nullable(String),
    city              Nullable(String),
    region            Nullable(String),
    postal_code       Nullable(String),
    country           Nullable(String),
    home_phone        Nullable(String),
    extension         Nullable(String),
    notes             Nullable(String),
    photo_path        Nullable(String),
    _ingested_at      DateTime DEFAULT now(),
    _source           String   DEFAULT 'postgresql'
)
ENGINE = MergeTree()
ORDER BY employee_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_shippers (
    shipper_id   Int32,
    company_name Nullable(String),
    phone        Nullable(String),
    _ingested_at DateTime DEFAULT now(),
    _source      String   DEFAULT 'postgresql'
)
ENGINE = MergeTree()
ORDER BY shipper_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_territories (
    territory_id          String,
    territory_description Nullable(String),
    region_id             Nullable(Int32),
    _ingested_at          DateTime DEFAULT now(),
    _source               String   DEFAULT 'postgresql'
)
ENGINE = MergeTree()
ORDER BY territory_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bronze.raw_region (
    region_id          Int32,
    region_description Nullable(String),
    _ingested_at       DateTime DEFAULT now(),
    _source            String   DEFAULT 'postgresql'
)
ENGINE = MergeTree()
ORDER BY region_id;