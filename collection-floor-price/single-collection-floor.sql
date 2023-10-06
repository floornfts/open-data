WITH all_prices AS (
SELECT
  date,
  collection_id,
  AVG(floor_price) as floor_price,
  ROW_NUMBER() OVER(PARTITION BY collection_id ORDER BY date DESC) as rn
FROM
  `floor-public-datasets.stats.collection-floor-hourly`
WHERE
  date > TIMESTAMP_SUB(CURRENT_TIMESTAMP, INTERVAL 1 DAY)
  AND collection_id IN ('claynosaurz',
    'mad_lads',
    'degenerate_ape_academy',
    'famous_fox_federation',
    'stylish_studs')
  
GROUP BY
  1,
  2
ORDER BY
  1 DESC
)

SELECT * EXCEPT(rn) FROM all_prices where rn = 1