-- ══════════════════════════════════════════════
-- SILVER — Todas las tablas staging (stg_*)
-- Datos limpios, tipos correctos, sin modelo aún
-- ══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS silver.stg_customers (
    customer_id   String,
    company_name  String,
    contact_name  String,
    contact_title String,
    address       String,
    city          String,
    region        String,
    postal_code   String,
    country       String,
    phone         String,
    fax           String,
    _processed_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY customer_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_orders (
    order_id         Int32,
    customer_id      String,
    employee_id      Int32,
    order_date       Date,
    required_date    Nullable(Date),
    shipped_date     Nullable(Date),
    ship_via         Int32,
    freight          Float64,
    ship_name        String,
    ship_address     String,
    ship_city        String,
    ship_region      String,
    ship_postal_code String,
    ship_country     String,
    _processed_at    DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY order_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_order_details (
    order_id      Int32,
    product_id    Int32,
    unit_price    Float64,
    quantity      Int32,
    discount      Float64,
    _processed_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY (order_id, product_id);

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_products (
    product_id        Int32,
    product_name      String,
    supplier_id       Int32,
    category_id       Int32,
    quantity_per_unit String,
    unit_price        Float64,
    units_in_stock    Int32,
    units_on_order    Int32,
    reorder_level     Int32,
    discontinued      Int8,
    _processed_at     DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY product_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_categories (
    category_id   Int32,
    category_name String,
    description   String,
    _processed_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY category_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_suppliers (
    supplier_id   Int32,
    company_name  String,
    contact_name  String,
    contact_title String,
    address       String,
    city          String,
    region        String,
    postal_code   String,
    country       String,
    phone         String,
    fax           String,
    homepage      String,
    _processed_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY supplier_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_employees (
    employee_id       Int32,
    last_name         String,
    first_name        String,
    full_name         String,
    title             String,
    title_of_courtesy String,
    birth_date        Nullable(Date),
    hire_date         Nullable(Date),
    address           String,
    city              String,
    region            String,
    postal_code       String,
    country           String,
    home_phone        String,
    extension         String,
    notes             String,
    _processed_at     DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY employee_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_shippers (
    shipper_id    Int32,
    company_name  String,
    phone         String,
    _processed_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY shipper_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_territories (
    territory_id          String,
    territory_description String,
    region_id             Int32,
    _processed_at         DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY territory_id;

-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS silver.stg_region (
    region_id          Int32,
    region_description String,
    _processed_at      DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(_processed_at)
ORDER BY region_id;