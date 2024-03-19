CREATE TABLE prodej
(
  id INT,
  zakaznik VARCHAR(100),
  celkem DECIMAL(8,2)
);

INSERT INTO prodej VALUES (1, 'Dovoz potravin, s.r.o.', 150000);
INSERT INTO prodej VALUES (2, 'Prodej textilu, a.s.', 20000);
INSERT INTO prodej VALUES (3, 'Zážitková agentura, s.r.o.', 350000);
INSERT INTO prodej VALUES (4, 'Restaurace a stravování, spol s r.o.', 1000);
INSERT INTO prodej VALUES (5, 'Průmysl, a.s.', 900000);
