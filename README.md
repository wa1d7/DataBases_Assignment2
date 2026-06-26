# query optimization report

## 1. unoptimized query (original)
* execution time: 2423.358 ms
* planning time: 37.530 ms
* total cost: 39457.13
* buffers shared hit: 20059
* summary: database did double the work because it ran multiple heavy subqueries and joined the same tables twice

## 2. optimized query (with cte and window functions)
* execution time: 1299.315 ms
* planning time: 17.039 ms
* total cost: 19729.20
* buffers shared hit: 10028
* summary: time and cost dropped by almost 50% because we combined data once using cte

## 3. optimized query with index scan off (extra points)
* execution time: 1294.035 ms
* planning time: 1.693 ms
* total cost: 19729.20
* buffers shared hit: 10028
* summary: execution time stayed about the same but planning time dropped from 17ms to 1.6ms since it skipped checking indexes
