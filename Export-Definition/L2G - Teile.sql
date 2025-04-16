SELECT EinzTeil.Code AS EPC, Artikel.ArtikelNr AS ARTIKELNR, EinzTeil.Anlage_ AS REGDATE, Mitarbei.UserName AS REGUSER
FROM EinzTeil
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN Mitarbei ON EinzTeil.AnlageUserID_ = Mitarbei.ID
WHERE (Artikel.ArtikelNr LIKE 'L2G%' OR Artikel.ArtikelNr IN ('G10100', 'G20100', 'G30114', 'G30118'));