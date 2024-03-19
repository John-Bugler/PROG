/* Vytvoř tabulku BAND */
CREATE TABLE BAND
(
  id INT,
  name VARCHAR(50)
);

/* Vlož záznamy */
INSERT INTO BAND VALUES(1, 'John Lennon');
INSERT INTO BAND VALUES(2, 'Paul McCartney');
INSERT INTO BAND VALUES(3, 'George Harrison');
INSERT INTO BAND VALUES(4, 'Ringo Starr');

/* Vyber Ringa */
SELECT *
  FROM BAND
  WHERE name = 'Ringo Starr';
