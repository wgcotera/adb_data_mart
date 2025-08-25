USE dm_ecommerce;

-- =========== DIMENSIONES ===========
-- Clientes (SCD Tipo 1 por ahora)
CREATE TABLE IF NOT EXISTS dim_customer (
  customer_sk        INT AUTO_INCREMENT PRIMARY KEY,
  customer_id        INT NOT NULL UNIQUE,          -- clave natural
  email              VARCHAR(255),
  first_name         VARCHAR(100),
  last_name          VARCHAR(100),
  gender             CHAR(1),
  country            VARCHAR(100),
  city               VARCHAR(100),
  postal_code        VARCHAR(20),
  address            VARCHAR(500),
  customer_segment   VARCHAR(50),
  marketing_consent  TINYINT,
  is_active          TINYINT,
  registration_date  DATE,
  last_login         DATETIME,
  INDEX idx_cust_city(city),
  INDEX idx_cust_segment(customer_segment)
);

-- Categorías
CREATE TABLE IF NOT EXISTS dim_category (
  category_sk     INT AUTO_INCREMENT PRIMARY KEY,
  category_id     INT NOT NULL UNIQUE,
  category_name   VARCHAR(255) NOT NULL,
  parent_category VARCHAR(255),
  created_at      DATETIME
);

-- Productos
CREATE TABLE IF NOT EXISTS dim_product (
  product_sk      INT AUTO_INCREMENT PRIMARY KEY,
  product_id      INT NOT NULL UNIQUE,
  product_name    VARCHAR(255) NOT NULL,
  brand           VARCHAR(255),
  category_id     INT,
  category_name   VARCHAR(255),
  price           DECIMAL(12,2),
  cost            DECIMAL(12,2),
  stock_quantity  INT,
  weight_kg       DECIMAL(10,3),
  dimensions      VARCHAR(100),
  description     TEXT,
  is_active       TINYINT,
  created_at      DATETIME,
  INDEX idx_prod_brand(brand),
  INDEX idx_prod_category(category_id)
);

-- Métodos de pago
CREATE TABLE IF NOT EXISTS dim_payment_method (
  payment_method_sk INT AUTO_INCREMENT PRIMARY KEY,
  payment_method    VARCHAR(50) NOT NULL UNIQUE
);

-- Estados de la orden
CREATE TABLE IF NOT EXISTS dim_order_status (
  order_status_sk INT AUTO_INCREMENT PRIMARY KEY,
  order_status    VARCHAR(50) NOT NULL UNIQUE
);

-- NOTA: dim_date ya existe como dm_ecommerce.dim_date (cargada antes)

-- =========== HECHO ===========
-- Grano: UNA FILA POR ÍTEM DE PEDIDO (order_items)
CREATE TABLE IF NOT EXISTS fact_order_items (
  fact_sk             BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_item_id       INT NOT NULL,
  order_id            INT NOT NULL,
  order_date_sk       INT NOT NULL,               -- FK a dim_date.date_sk
  customer_sk         INT NOT NULL,
  product_sk          INT NOT NULL,
  payment_method_sk   INT,
  order_status_sk     INT,
  -- Métricas principales
  quantity            INT,
  unit_price          DECIMAL(12,2),
  line_total          DECIMAL(12,2),
  discount_amount     DECIMAL(12,2),
  -- Métricas a nivel orden 
  order_subtotal      DECIMAL(12,2),
  order_tax_amount    DECIMAL(12,2),
  order_shipping_cost DECIMAL(12,2),
  order_total_amount  DECIMAL(12,2),
  currency            VARCHAR(10),
  -- Índices para performance
  KEY idx_f_order_date (order_date_sk),
  KEY idx_f_customer   (customer_sk),
  KEY idx_f_product    (product_sk),
  KEY idx_f_order      (order_id)
);

ALTER TABLE fact_order_items
  MODIFY order_item_id BIGINT NOT NULL AUTO_INCREMENT;

