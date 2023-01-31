all_refunds as (
 SELECT
   global_entity_id,
   order_code,
   ROUND(refund_value_eur, 4) AS refund_value_eur,
 FROM non_compensation_oneview_refunds
 UNION ALL
 SELECT
   global_entity_id,
   order_code,
   ROUND(refund_value_eur, 4) AS refund_value_eur,
 FROM non_vendor_basket_update_refunds
),
--
orders_with_customer_refund AS (
 SELECT
   DISTINCT
     global_entity_id,
     order_code,
     refund_value_eur,
 FROM all_refunds
