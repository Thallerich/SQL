DECLARE @von TIMESTAMP;
DECLARE @bis TIMESTAMP;

@von = CONVERT($3$ + ' 00:00:00', SQL_TIMESTAMP);
@bis = CONVERT($4$ + ' 23:59:59', SQL_TIMESTAMP);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.WaschPreis, KdArti.LeasingPreis, KdArti.Anlage_ AS Anlage, KdArti.AnlageUser_ AS AnlageUser
FROM KdArti, Artikel, Kunden
WHERE KdArti.ArtikelID = Artikel.ID
  AND KdArti.KundenID = Kunden.ID
  AND Kunden.KdGfID IN ($1$)
  AND IIF($2$ = TRUE, Artikel.ArtikelNr LIKE '1298%', 1 = 1)
  AND KdArti.Anlage_ BETWEEN @von AND @bis
ORDER BY Kunden.KdNr, Artikel.ArtikelNr;