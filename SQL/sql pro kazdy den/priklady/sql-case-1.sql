CREATE TABLE kurzy
( 
    id INT, 
    nazev VARCHAR(50), 
    cena  DECIMAL(7,2),
    v_prodeji BOOLEAN,
    prodano_licenci INT  
); 


INSERT INTO kurzy VALUES (1, 'SQL základy', 3900, 1, 120);
INSERT INTO kurzy VALUES (2, 'Python úvod', 4100, 1, 140);
INSERT INTO kurzy VALUES (3, 'Excel KT', 3100, 1, 330);
INSERT INTO kurzy VALUES (4, 'Power BI', 3900, 1, 210);
INSERT INTO kurzy VALUES (5, 'Tableau', 4300, 1, 190);
INSERT INTO kurzy VALUES (6, 'Android', 3100, 1, 40);
INSERT INTO kurzy VALUES (7, 'RPA', 3100, 1, 50);
INSERT INTO kurzy VALUES (8, 'Strojové učení', 4800, 1, 30);
INSERT INTO kurzy VALUES (9, 'Základy jógy', 2900, 0, 0);
