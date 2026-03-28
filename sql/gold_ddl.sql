-- ══════════════════════════════════════════════
-- GOLD — Dimensiones (dim_*)
-- Desnormalizadas, listas para el Star Schema
-- ══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS gold.dim_customers (
    customer_id   String,
    company_name  String,
    contact_name  String,
    contact_title String,
    city          String,
    region        String,
    country       String,
    phone         String,
    _valid_from   DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_valid_from)
ORDER BY customer_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS gold.dim_employees (
    employee_id       Int32,
    full_name         String,
    title             String,
    title_of_courtesy String,
    birth_date        Nullable(Date),
    hire_date         Nullable(Date),
    city              String,
    region            String,
    country           String,
    _valid_from       DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_valid_from)
ORDER BY employee_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS gold.dim_products (
    product_id        Int32,
    product_name      String,
    category_name     String,
    supplier_name     String,
    supplier_country  String,
    quantity_per_unit String,
    list_price        Float64,
    discontinued      Int8,
    _valid_from       DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_valid_from)
ORDER BY product_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS gold.dim_shippers (
    shipper_id   Int32,
    company_name String,
    phone        String,
    _valid_from  DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_valid_from)
ORDER BY shipper_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS gold.dim_territories (
    territory_id          String,
    territory_description String,
    region_id             Int32,
    region_description    String,
    _valid_from           DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_valid_from)
ORDER BY territory_id;

-- ──────────────────────────────────────────────

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
)
ENGINE = MergeTree()
ORDER BY date_key;

-- ══════════════════════════════════════════════
-- GOLD — Tabla de hechos (fact_*)
-- Granularidad: línea de pedido
-- ══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS gold.fact_sales (
    order_id     Int32,
    date_key     Int32,      -- FK → dim_date
    customer_id  String,     -- FK → dim_customers
    employee_id  Int32,      -- FK → dim_employees
    product_id   Int32,      -- FK → dim_products
    shipper_id   Int32,      -- FK → dim_shippers
    sale_price   Float64,    -- precio real de venta
    quantity     Int32,
    discount     Float64,
    line_total   Float64,
    freight      Float64
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(toDate(toString(date_key)))
ORDER BY (date_key, customer_id, order_id, product_id);