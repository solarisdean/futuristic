WITH gmv_allorders AS (
    SELECT
      code,
      d_orders_accounting.global_id,
      calculated_total_local,
      gmv_local,
      gmv_fcy
    FROM d_orders
    LEFT JOIN d_orders_accounting
           ON d_orders_accounting.global_id = d_orders.global_id
          AND d_orders_accounting.uuid = d_orders.uuid
    WHERE d_orders`.created_date_utc BETWEEN '2022-04-02' AND '2022-04-15'
    AND d_orders_accounting`.created_date_utc BETWEEN '2022-04-02' AND '2022-04-15'
    ), gmv_joker AS (
    SELECT
      tests.adtech_experiment.global_id,
      CASE
        WHEN tests.adtech_experiment.global_id = 'GI_ID' THEN 'Indonesia'
        WHEN tests.adtech_experiment.global_id = 'GI_MY' THEN 'Malaysia'
        WHEN tests.adtech_experiment.global_id = 'GI_PH' THEN 'Philippines'
        WHEN tests.adtech_experiment.global_id = 'GI_SG' THEN 'Singapore'
        WHEN tests.adtech_experiment.global_id = 'GI_TH' THEN 'Thailand'
        ELSE 'unknown'
        END AS country,
      test_variant,
      event_action,
      order_code,
      gmv_fcy,
      gmv_local
    FROM tests.adtech_experiment    
    LEFT JOIN gmv_allorders
           ON tests.adtech_experiment.global_id = gmv_allorders.global_id
           AND tests.adtech_experiment.order_code = gmv_allorders.code
    ), avg_gmv_joker AS (
    SELECT
      country,
      test_variant,
      AVG(gmv_fcy) AS avg_gmv_fcy
    FROM gmv_joker
    GROUP BY country, test_variant
    ), diff_gmv AS (
    SELECT
      country,
      test_variant,
      avg_gmv_fcy,
      FIRST_VALUE(avg_gmv_fcy) OVER (PARTITION BY country ORDER BY test_variant ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS control_avg_gmv_fcy,
    FROM avg_gmv_joker
    )
SELECT
  country,
  test_variant,
  avg_gmv_fcy,
  SAFE_DIVIDE(SAFE_SUBTRACT(avg_gmv_fcy,control_avg_gmv_fcy),control_avg_gmv_fcy) AS gmv_fcy_diff
FROM diff_gmv
ORDER BY country, test_variant, gmv_fcy_diff
