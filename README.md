# Proyecto Data Mart de E-commerce

## 📊 Descripción

Este proyecto implementa un **Data Mart orientado a ventas** utilizando el enfoque de modelado dimensional de Kimball.  
El flujo incluye:

- Extracción, transformación y carga (ETL) con **Pentaho Data Integration (WebSpoon)**.
- Almacenamiento en **MySQL 8.0**.
- Construcción de dashboards interactivos en **Power BI**.

Dataset seleccionado de Kaggle:  
👉 [E-commerce Fake Data](https://www.kaggle.com/datasets/sachingupta26/ecommercefakedata)

---

## 🚀 Proceso seguido

1. **Carga a Staging**

   - Limpieza de fechas (`order_date`, `created_at`, `updated_at`)
   - Normalización de `order_date_sk` a formato `YYYYMMDD`

2. **Construcción de Dimensiones**

   - `dim_date`, `dim_customer`, `dim_product`, `dim_category`, `dim_order_status`, `dim_payment_method`

3. **Carga de Hechos**

   - `fact_order_items` con granularidad a nivel de ítem de pedido
   - Métricas: `gross_amount`, `discount_amount`, `net_amount`, `margin_amount`

4. **Vista para BI**
   - `vw_sales_order_items` con joins a dimensiones para exponer campos listos para Power BI

---

## 📊 Dashboards en Power BI

- Tendencia de ventas en el tiempo
- Ventas por categoría
- Top clientes por facturación
- Distribución de métodos de pago
- Margen bruto por categoría

👉 [Ver Dashboard de PowerBi](https://app.powerbi.com/view?r=eyJrIjoiMDBkMGI2YWEtYzNiYS00ZjNhLThlOWItODk5MzY3YzYyZTNmIiwidCI6ImI3YWY4Y2FmLTgzZDgtNDY0NC04NWFlLTMxN2M1NDUyMjNjMSIsImMiOjR9).

---

## 📑 Requisitos de negocio e indicadores

| Indicador             | Variables principales                             | Visualización sugerida       |
| --------------------- | ------------------------------------------------- | ---------------------------- |
| Ventas netas          | quantity, unit_price, discount_amount, net_amount | Tarjeta KPI + línea temporal |
| Ticket promedio (AOV) | net_amount, order_id                              | Tarjeta KPI + línea          |
| Margen bruto %        | net_amount, cost_amount, margin_amount            | Barra / semáforo             |
| Tasa de recompra      | customer_id                                       | Barra temporal               |
| Rating promedio       | reviews.rating, product_id                        | Gráfico de barras            |
| Stock crítico         | inventory.stock_quantity, category_name           | Tarjeta + barra              |

---

## ⚙️ Ejecución

1. Levantar contenedores con Docker Compose (`mysql`, `adminer`, `webspoon`).
2. Ejecutar transformaciones en Pentaho en orden:
   - `01_full_staging`
   - `02_dim_build`
   - `03_fact_load_order_items_load`
3. Validar dimensiones y hechos en MySQL.
4. Conectar Power BI a la vista `vw_sales_order_items`.

---

**Sistemas de Bases de Datos Avanzados**
