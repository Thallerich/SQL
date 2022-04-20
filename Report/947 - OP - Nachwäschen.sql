DECLARE @from datetime2 = CAST($STARTDATE$ AS datetime2);
DECLARE @to datetime2 = CAST(DATEADD(day, 1, $ENDDATE$) AS datetime2);

WITH OPScansAll AS (
  SELECT Scans.ID, Scans.EinzTeilID, Scans.[DateTime] AS Zeitpunkt, Scans.ZielNrID, Scans.AnlageUserID_
  FROM Scans
  WHERE Scans.[DateTime] BETWEEN @from AND @to
    AND Scans.ZielNrID IN (10000020, 10000021, 10000022, 10000019, 10000031)
    AND Scans.EinzTeilID > 0

  UNION ALL

  SELECT OPScans.ID, OPScans.OPTeileID AS EinzTeilID, OPScans.Zeitpunkt, OPScans.ZielNrID, OPScans.AnlageUserID_
  FROM Salesianer_Archive..OPScans
  WHERE OPScans.Zeitpunkt BETWEEN @from AND @to
    AND OPScans.ZielNrID IN (10000020, 10000021, 10000022, 10000019, 10000031)
)
SELECT Kunden.KdNr, IIF(Kunden.ID < 0, N'(unbekannt)', Kunden.SuchCode) AS Kunde, Vsa.VsaNr, IIF(Vsa.ID < 0, N'(unbekannt)', Vsa.Bez) AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, CAST(OPScansAll.Zeitpunkt AS date) AS Tag, ZielNr.ZielNrBez AS [Nachwäsche-Grund], COUNT(DISTINCT OPTeile.ID) AS [Anzahl Nachwäsche-Teile], COUNT(OPScansAll.ID) AS [Anzahl Nachwäschen]
FROM OPScansAll
JOIN OPTeile ON OPScansAll.EinzTeilID = OPTeile.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN ZielNr ON OPScansAll.ZielNrID = ZielNr.ID
JOIN Mitarbei ON OPScansAll.AnlageUserID_ = Mitarbei.ID
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Mitarbei.StandortID IN ($2$)
GROUP BY Kunden.KdNr, IIF(Kunden.ID < 0, N'(unbekannt)', Kunden.SuchCode), Vsa.VsaNr, IIF(Vsa.ID < 0, N'(unbekannt)', Vsa.Bez), Artikel.ArtikelNr, Artikel.ArtikelBez, CAST(OPScansAll.Zeitpunkt AS date), ZielNr.ZielNrBez
ORDER BY Tag, [Nachwäsche-Grund], Artikelbezeichnung;