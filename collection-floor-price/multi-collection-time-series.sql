SELECT
  TIMESTAMP_TRUNC(date, day) AS date,
  collection_id,
  AVG(floor_price) as floor_price
FROM
  `floor-public-datasets.stats.collection-floor-hourly`
WHERE
  date > TIMESTAMP_SUB(CURRENT_TIMESTAMP, INTERVAL 30 DAY)
  AND collection_id IN ('claynosaurz',
    'mad_lads',
    'degenerate_ape_academy',
    'famous_fox_federation',
    'stylish_studs')
GROUP BY
  1,
  2
ORDER BY 1 DESC
