non_compensation_refunds as ( 
SELECT
   DISTINCT
   refund_events.global_id,
   refund_events.order_code,
   refund_value_eur,
 FROM refund_events
 WHERE refund_events.created_date_utc BETWEEN '2022-07-01' AND '2022-09-26'
   AND refund_events.event_type != "Compensation"
   AND global_entity_id IN ('GI_SG')
