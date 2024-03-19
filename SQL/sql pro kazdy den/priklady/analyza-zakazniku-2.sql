SELECT *
  FROM prodej
  WHERE celkem = (
    SELECT MAX(celkem)
      FROM prodej
    );
