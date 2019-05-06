DECLARE @from datetime2 = CAST($1$ AS datetime);
DECLARE @to datetime2 = CAST(DATEADD(day, 1, $2$) AS datetime);

SELECT Kunden.KdNr, IIF(Kunden.ID < 0, N'(unbekannt)', Kunden.SuchCode) AS Kunde, Vsa.VsaNr, IIF(Vsa.ID < 0, N'(unbekannt)', Vsa.Bez) AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, CAST(OPScans.Zeitpunkt AS date) AS Tag, ZielNr.ZielNrBez AS [Nachwäsche-Grund], COUNT(DISTINCT OPTeile.ID) AS [Anzahl Nachwäsche-Teile], COUNT(OPScans.ID) AS [Anzahl Nachwäschen]
FROM OPScans
JOIN OPTeile ON OPScans.OPTeileID = OPTeile.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN ZielNr ON OPScans.ZielNrID = ZielNr.ID
JOIN Mitarbei ON OPScans.AnlageUserID_ = Mitarbei.ID
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE OPScans.Zeitpunkt BETWEEN @from AND @to
  AND OPScans.ZielNrID IN (10000020, 10000021, 10000022, 10000019, 10000031)
  AND Mitarbei.StandortID IN ($3$)
GROUP BY Kunden.KdNr, IIF(Kunden.ID < 0, N'(unbekannt)', Kunden.SuchCode), Vsa.VsaNr, IIF(Vsa.ID < 0, N'(unbekannt)', Vsa.Bez), Artikel.ArtikelNr, Artikel.ArtikelBez, CAST(OPScans.Zeitpunkt AS date), ZielNr.ZielNrBez
ORDER BY Tag, [Nachwäsche-Grund], Artikelbezeichnung;