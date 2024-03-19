SELECT *
  FROM prodej
  WHERE celkem = (
    SELECT MIN(celkem)
      FROM prodej
    );
