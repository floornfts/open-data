# Collection Floor Prices

<p align="center">
  <img src="https://github.com/floornfts/open-data/assets/1068437/6d113ed2-6ba9-4c69-a72c-eb14f9c0d39c" width="400" />
  <br />
  <em style="max-width:300px">This is a real-time replica of the data that powers the Floor app graphs for Solana collections.</em>
</p>

## About this dataset
The Collection Floor prices data set contains:
* Floor prices for all Solana collections
* Beginning March 21 2023
* Indexed by the `collection_id` (MagicEden or OpenSea slug) or `collection_contract` (minting program).
* Captured every hour on the hour, meaning a collection that existed on in March now has almost 10,000 records capturing history


## Getting Access
You can find the dataset here → <a target="_blank" href="https://console.cloud.google.com/bigquery?project=floor-public-datasets&ws=!1m14!1m4!4m3!1sfloor-public-datasets!2sstats!3scollection-floor-hourly!1m4!1m3!1sfloor-public-datasets!2sbquxjob_5f5b1197_18b858eb336!3sUS!1m3!3m2!1sfloor-public-datasets!2sstats">floor-public-datasets</a>, or simply reference the table in any query as `floor-public-datasets.stats.collection-floor-hourly`.

![CleanShot 2023-10-06 at 08 16 09@2x](https://github.com/floornfts/open-data/assets/1068437/7ce3b342-c71c-42dd-9857-3129a09bcf9c)

## Usage
### Getting a Collection floor Price
BigQuery is best used for pulling large sets of data and aggregations, but for a simple example, here we will get the latest floor price for a list of collections.

This uses a `WITH` command to create a table of all prices, indicating a ROW_NUMBER (rn), grouped by the `collection_id` and then filters to the "first row".

Amusingly, the SQL to get a single, latest collection floor price is more complicated than much more complex aggregations. This is a good reminder of what BQ is and isn't really designed for.

```sql
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
```
### Getting a timeseries of collection prices
Let's start doing some interesting things with the data, starting with a time series.

Here we're going to get the values of collection floor prices over time, and plot them on a chart.

<p align="center">
<img src="https://github.com/floornfts/open-data/assets/1068437/903ed24b-6ac5-4f68-97da-81389ab6f201" width="500" />
</p>

```sql
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
```

We can now use Looker Studio (a free Google product integrated into BigQuery) to visualize this data, export to Sheets etc...

<br/>

## BigQuery Tips
### Costs
This public dataset is made available for free, but using BigQuery to query it may not be free. Google will charge you per bytes of data queried in accordance with [BigQuery Pricing](https://cloud.google.com/bigquery/pricing).

Generally speaking, querying is ~$6/TB of data queried (check the link for the latest pricing) and at time of publishing this entire dataset is 20GB (so approximately $0.12 to scan the entire dataset for all collections.)

You can dramatically reduce this cost by utilizing the clustered fields and partitioned fields below for filtering.

<br/>

### Partitioning & Clustering
BigQuery has two concepts that massively reduce the costs of querying datasets in most scenarios:

* Partitioning -- loading only information that relates to the date range you are interested in
* Clustering -- reducing data loaded based on a hash of the clustered field (in this case collection_id)

Specifying a `date` range or a `collection_id` will massively reduce the amount of data loaded.

e.g.
This query loads 20GB of data (~$0.12 at time of writing)
```sql
SELECT * FROM `floor-public-datasets.stats.collection-floor-hourly`
```

This query loads 80MB of data (~$0.0005, huzzah!)
```sql
SELECT * FROM `floor-public-datasets.stats.collection-floor-hourly`
WHERE date = TIMESTAMP("2023-10-31")
```
<br/>

### Viualizing Data in Looker Studio
You can easily take the output of any query and export it to Google Sheets or Looker Studio.

<img src="https://github.com/floornfts/open-data/assets/1068437/ec9614e0-81c6-4958-9df9-e1f1b3bb54f2" width="300" />

From here, you can quickly create graphs like this one with a few clicks:
![CleanShot 2023-10-31 at 09 07 23@2x](https://github.com/floornfts/open-data/assets/1068437/dfa5161e-b99f-4cfc-937c-01c82d704779)


