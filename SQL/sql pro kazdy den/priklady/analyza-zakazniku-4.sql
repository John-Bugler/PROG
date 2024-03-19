-- PostgreSQL
SELECT *
  FROM prodej
  ORDER BY celkem DESC
  LIMIT 3;

-- SQL Server
SELECT TOP 3 *
  FROM prodej
  ORDER BY celkem DESC
