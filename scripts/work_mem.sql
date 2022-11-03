SELECT 5000 + random() * 5000 AS w_m \gset
ALTER SYSTEM SET work_mem = :w_m;
SELECT pg_reload_conf();
