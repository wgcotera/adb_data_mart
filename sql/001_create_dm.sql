-- Base
CREATE DATABASE IF NOT EXISTS dm_ecommerce
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE dm_ecommerce;

-- =========================
-- STAGING (copia “raw/typed”)
-- =========================
DROP TABLE IF EXISTS stg_categories;
CREATE TABLE stg_categories (
  category_id       BIGINT,
  category_name     VARCHAR(255),
  parent_category   VARCHAR(255),
  created_at        DATETIME
);

DROP TABLE IF EXISTS stg_customers;
CREATE TABLE stg_customers (
  customer_id       BIGINT,
  email             VARCHAR(255),
  first_name        VARCHAR(100),
  last_name         VARCHAR(100),
  phone             VARCHAR(50),
  date_of_birth     DATE,
  gender            VARCHAR(20),
  country           VARCHAR(100),
  city              VARCHAR(100),
  postal_code       VARCHAR(20),
  address           VARCHAR(255),
  registration_date DATE,
  last_login        DATETIME,
  is_active         TINYINT(1),
  customer_segment  VARCHAR(50),
  marketing_consent TINYINT(1)
);

DROP TABLE IF EXISTS stg_inventory_logs;
CREATE TABLE stg_inventory_logs (
  log_id           BIGINT,
  product_id       BIGINT,
  movement_type    VARCHAR(50),
  quantity_change  INT,
  reason           VARCHAR(255),
  `timestamp`      DATETIME,
  reference_id     VARCHAR(100),
  notes            VARCHAR(255)
);

DROP TABLE IF EXISTS stg_order_items;
CREATE TABLE stg_order_items (
  order_item_id    BIGINT,
  order_id         BIGINT,
  product_id       BIGINT,
  quantity         INT,
  unit_price       DECIMAL(12,2),
  line_total       DECIMAL(12,2),
  discount_amount  DECIMAL(12,2)
);

DROP TABLE IF EXISTS stg_orders;
CREATE TABLE stg_orders (
  order_id         BIGINT,
  customer_id      BIGINT,
  order_date       DATETIME,
  status           VARCHAR(50),
  payment_method   VARCHAR(50),
  shipping_address TEXT,
  billing_address  TEXT,
  discount_amount  DECIMAL(12,2),
  tax_amount       DECIMAL(12,2),
  shipping_cost    DECIMAL(12,2),
  total_amount     DECIMAL(12,2),
  currency         VARCHAR(10),
  created_at       DATETIME,
  updated_at       DATETIME,
  subtotal         DECIMAL(12,2)
);

DROP TABLE IF EXISTS stg_products;
CREATE TABLE stg_products (
  product_id      BIGINT,
  product_name    VARCHAR(255),
  category_id     BIGINT,
  brand           VARCHAR(100),
  price           DECIMAL(12,2),
  cost            DECIMAL(12,2),
  stock_quantity  INT,
  weight_kg       DECIMAL(9,3),
  dimensions      VARCHAR(100),
  description     TEXT,
  is_active       TINYINT(1),
  created_at      DATETIME
);

DROP TABLE IF EXISTS stg_reviews;
CREATE TABLE stg_reviews (
  review_id            BIGINT,
  customer_id          BIGINT,
  product_id           BIGINT,
  rating               TINYINT,
  title                VARCHAR(255),
  comment              TEXT,
  is_verified_purchase TINYINT(1),
  helpful_votes        INT,
  created_at           DATETIME
);

-- =========================
-- DIMENSIONES
-- =========================
DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date (
  date_sk        INT PRIMARY KEY,            -- yyyymmdd
  full_date      DATE NOT NULL,
  day            TINYINT NOT NULL,
  month          TINYINT NOT NULL,
  month_name     VARCHAR(20) NOT NULL,
  year           SMALLINT NOT NULL,
  quarter        TINYINT NOT NULL,
  week_of_year   TINYINT NOT NULL,
  is_weekend     TINYINT(1) NOT NULL
);

DROP TABLE IF EXISTS dim_category;
CREATE TABLE dim_category (
  category_sk      INT AUTO_INCREMENT PRIMARY KEY,
  category_id_nk   BIGINT UNIQUE,            -- clave natural
  category_name    VARCHAR(255),
  parent_category  VARCHAR(255)
);

DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product (
  product_sk        BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id_nk     BIGINT UNIQUE,
  product_name      VARCHAR(255),
  brand             VARCHAR(100),
  price_current     DECIMAL(12,2),
  cost_current      DECIMAL(12,2),
  weight_kg         DECIMAL(9,3),
  dimensions        VARCHAR(100),
  description       TEXT,
  is_active         TINYINT(1),
  created_date_sk   INT,
  category_sk       INT,
  INDEX idx_dim_product_category (category_sk)
);

DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
  customer_sk       BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id_nk    BIGINT UNIQUE,
  email             VARCHAR(255),
  first_name        VARCHAR(100),
  last_name         VARCHAR(100),
  phone             VARCHAR(50),
  date_of_birth     DATE,
  gender            VARCHAR(20),
  country           VARCHAR(100),
  city              VARCHAR(100),
  postal_code       VARCHAR(20),
  address           VARCHAR(255),
  registration_date_sk INT,
  last_login_date_sk   INT,
  is_active         TINYINT(1),
  customer_segment  VARCHAR(50),
  marketing_consent TINYINT(1)
);

DROP TABLE IF EXISTS dim_status;
CREATE TABLE dim_status (
  status_sk    INT AUTO_INCREMENT PRIMARY KEY,
  status_name  VARCHAR(50) UNIQUE
);

DROP TABLE IF EXISTS dim_payment_method;
CREATE TABLE dim_payment_method (
  payment_method_sk INT AUTO_INCREMENT PRIMARY KEY,
  method_name       VARCHAR(50) UNIQUE
);

DROP TABLE IF EXISTS dim_movement_type;
CREATE TABLE dim_movement_type (
  movement_type_sk INT AUTO_INCREMENT PRIMARY KEY,
  movement_type_name VARCHAR(50) UNIQUE
);

-- =========================
-- HECHOS
-- =========================

DROP TABLE IF EXISTS fact_order_items;
CREATE TABLE fact_order_items (
  order_item_id     BIGINT PRIMARY KEY,
  order_id          BIGINT NOT NULL,         -- DD
  order_date_sk     INT NOT NULL,
  customer_sk       BIGINT NULL,
  product_sk        BIGINT NOT NULL,
  status_sk         INT NULL,
  payment_method_sk INT NULL,
  currency          VARCHAR(10),
  quantity          INT,
  unit_price        DECIMAL(12,2),
  gross_amount      DECIMAL(12,2),
  discount_amount   DECIMAL(12,2),
  net_amount        DECIMAL(12,2),
  cost_amount       DECIMAL(12,2),
  margin_amount     DECIMAL(12,2),
  INDEX idx_foi_order_date (order_date_sk),
  INDEX idx_foi_product (product_sk),
  INDEX idx_foi_customer (customer_sk),
  INDEX idx_foi_order (order_id)
);

DROP TABLE IF EXISTS fact_orders;
CREATE TABLE fact_orders (
  order_id          BIGINT PRIMARY KEY,      -- DD
  order_date_sk     INT NOT NULL,
  customer_sk       BIGINT NOT NULL,
  status_sk         INT NOT NULL,
  payment_method_sk INT NOT NULL,
  currency          VARCHAR(10),
  created_date_sk   INT,
  updated_date_sk   INT,
  subtotal          DECIMAL(12,2),
  discount_amount   DECIMAL(12,2),
  tax_amount        DECIMAL(12,2),
  shipping_cost     DECIMAL(12,2),
  total_amount      DECIMAL(12,2),
  order_count       INT NOT NULL DEFAULT 1,
  INDEX idx_fact_orders_date (order_date_sk),
  INDEX idx_fact_orders_customer (customer_sk),
  INDEX idx_fact_orders_status (status_sk),
  INDEX idx_fact_orders_payment (payment_method_sk)
);

DROP TABLE IF EXISTS fact_inventory;
CREATE TABLE fact_inventory (
  log_id            BIGINT PRIMARY KEY,
  inventory_date_sk INT NOT NULL,
  product_sk        BIGINT NOT NULL,
  movement_type_sk  INT NOT NULL,
  quantity_change   INT,
  reference_id      VARCHAR(100),
  INDEX idx_finv_date (inventory_date_sk),
  INDEX idx_finv_product (product_sk),
  INDEX idx_finv_movement (movement_type_sk)
);

DROP TABLE IF EXISTS fact_reviews;
CREATE TABLE fact_reviews (
  review_id           BIGINT PRIMARY KEY,
  review_date_sk      INT NOT NULL,
  product_sk          BIGINT NOT NULL,
  customer_sk         BIGINT NULL,
  rating              TINYINT,
  helpful_votes       INT,
  is_verified_purchase TINYINT(1),
  review_count        INT NOT NULL DEFAULT 1,
  INDEX idx_fr_date (review_date_sk),
  INDEX idx_fr_product (product_sk),
  INDEX idx_fr_customer (customer_sk)
);
