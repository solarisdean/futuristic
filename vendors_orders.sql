WITH joker_local AS (
  SELECT
    event_timestamp_utc AS created_at_timestamp_utc,
    DATETIME_TRUNC(event_timestamp_utc, hour) AS timestamp_hour_utc,
    EXTRACT(HOUR FROM event_timestamp_utc) AS time_hour_utc,
    SAFE_CAST(EXTRACT(DAYOFWEEK FROM ordered_at_local) AS STRING) AS day_of_week_type,
    ordered_at_local,
    DATETIME_TRUNC(ordered_at_local, hour) AS ordered_hour_local,
    EXTRACT(HOUR FROM ordered_at_local) AS time_hour_local,
   tests.adtech_experiment.global_id,
   test_variant,
   event_action,
   vendor_codes AS vendor_listed,
   tests.adtech_experiment.vendor_code AS vendor_ordered,
   customer_code,
   CONCAT(cust_lat,',', cust_lon) AS cust_location_geo,
   order_code
 FROM tests.adtech_experiment
 LEFT JOIN d_orders
        ON d_orders.code =  tests.adtech_experiment.order_code
        AND d_orders.global_id =  tests.adtech_experiment.global_id
 WHERE created_date_utc BETWEEN "2022-04-02" AND "2022-04-15"
 ), joker_vendor AS (
  SELECT
    created_at_timestamp_utc,
    timestamp_hour_utc,
    time_hour_utc,
    day_of_week_type,
    CASE
       WHEN day_of_week_type = '1' THEN 'Sunday'
       WHEN day_of_week_type = '2' THEN 'Monday'
       WHEN day_of_week_type = '3' THEN 'Tuesday'
       WHEN day_of_week_type = '4' THEN 'Wednesday'
       WHEN day_of_week_type = '5' THEN 'Thursday'
       WHEN day_of_week_type = '6' THEN 'Friday'
       WHEN day_of_week_type = '7' THEN 'Saturday'
       ELSE 'unknown'
       END AS day_of_week,
    ordered_at_local,
    ordered_hour_local,
    time_hour_local,
    joker_local.global_id,
    CASE
       WHEN joker_local.global_id = 'GI_ID' THEN 'Indonesia'
       WHEN joker_local.global_id = 'GI_MY' THEN 'Malaysia'
       WHEN joker_local.global_id = 'GI_PH' THEN 'Philippines'
       WHEN joker_local.global_id = 'GI_SG' THEN 'Singapore'
       WHEN joker_local.global_id = 'GI_TH' THEN 'Thailand'
       ELSE 'unknown'
       END AS country,
    test_variant,
    event_action,
    order_code,
    customer_code,
    cust_location_geo,
    vendor_listed,
    vendor_ordered,
    name,
    chain_name,
    primary_cuisine,
    CONCAT(SAFE_CAST(location.latitude AS string), ',', SAFE_CAST(location.longitude AS STRING)) AS vendor_location_geo
   FROM joker_local
   LEFT JOIN d_vendors
          ON joker_local.global_id=d_vendors.global_id
         AND joker_local.vendor_ordered=d_vendors.vendor_code
 WHERE d_vendors.global_id  IN ('GI_PH', 'GI_ID', 'GI_SG', 'GI_MY', 'GI_TH')
), gmv_d_orders AS (
 SELECT
   code,
   d_orders_agg_accounting .global_id,
   calculated_total_local,
   gmv_local,
   gmv_eur
 FROM d_orders
 LEFT JOIN d_orders_agg_accounting
        ON d_orders_agg_accounting.global_id = d_orders.global_id
       AND d_orders_agg_accounting.uuid = d_orders.uuid
 WHERE d_orders.created_date_utc BETWEEN '2022-04-02' AND '2022-04-15'
 AND d_orders_agg_accountingcreated_date_utc BETWEEN '2022-04-02' AND '2022-04-15'
 ), 
SELECT
  created_at_timestamp_utc,
  timestamp_hour_utc,
  time_hour_utc,
  day_of_week,
  ordered_at_local,
  ordered_hour_local,
  time_hour_local,
  joker_vendor.global_id,
  country,
  test_variant,
  event_action,
  order_code,
  customer_code,
  cust_location_geo,
  vendor_listed,
  vendor_ordered,
  name,
  chain_name,
  primary_cuisine,
  vendor_location_geo,
  calculated_total_local,
  gmv_local,
  gmv_eur
FROM joker_vendor
LEFT JOIN gmv_d_orders
       ON joker_vendor.global_id = gmv_d_orders.global_id
      AND joker_vendor.order_code = gmv_d_orders.code
