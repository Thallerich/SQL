DECLARE @lastSunday date = CAST(DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6) AS date);
DECLARE @StandortID int = (SELECT Standort.ID FROM Standort WHERE Standort.SuchCode = N'WOLE');

WITH Leasingumsatz AS (
  SELECT KdArti.ArtikelID, Vsa.KundenID, AbtKdArW.Monat, CAST(SUM(AbtKdArW.Menge * AbtKdArW.EPreis) AS money) AS LeasingSumme
  FROM AbtKdArW
  JOIN KdArti ON AbtKdArW.KdArtiID = KdArti.ID
  JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
  WHERE AbtKdArW.Monat BETWEEN N'2020-01' AND N'2020-12'
  GROUP BY KdArti.ArtikelID, Vsa.KundenID, AbtKdArW.Monat
)
SELECT p.KdNr,
  p.Kunde,
  p.ArtikelNr,
  p.Artikelbezeichnung,
  p.Umlaufmenge,
  [2020-01] = ISNULL([2020-01], 0),
  [2020-02] = ISNULL([2020-02], 0),
  [2020-03] = ISNULL([2020-03], 0),
  [2020-04] = ISNULL([2020-04], 0),
  [2020-05] = ISNULL([2020-05], 0),
  [2020-06] = ISNULL([2020-06], 0),
  [2020-07] = ISNULL([2020-07], 0),
  [2020-08] = ISNULL([2020-08], 0),
  [2020-09] = ISNULL([2020-09], 0),
  [2020-10] = ISNULL([2020-10], 0),
  [2020-11] = ISNULL([2020-11], 0),
  [2020-12] = ISNULL([2020-12], 0),
  Summe = ISNULL([2020-01], 0) + ISNULL([2020-02], 0) + ISNULL([2020-03], 0) + ISNULL([2020-04], 0) + ISNULL([2020-05], 0) + ISNULL([2020-06], 0) + ISNULL([2020-07], 0) + ISNULL([2020-08], 0) + ISNULL([2020-09], 0) + ISNULL([2020-10], 0) + ISNULL([2020-11], 0) + ISNULL([2020-12], 0)
FROM (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, SUM(_Umlauf.Umlauf) AS Umlaufmenge, Leasingumsatz.Monat, Leasingumsatz.LeasingSumme
  FROM _Umlauf
  JOIN Artikel ON _Umlauf.ArtikelID = Artikel.ID
  JOIN KdArti ON _Umlauf.KdArtiID = KdArti.ID
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN Leasingumsatz ON Leasingumsatz.ArtikelID = Artikel.ID AND Leasingumsatz.KundenID = Kunden.ID
  WHERE _Umlauf.Datum = @lastSunday
    AND Kunden.StandortID = @StandortID
    AND Artikel.ArtikelNr IN (
      SELECT ArtikelNr
      FROM __PSAArti
    )
  GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, Leasingumsatz.Monat, Leasingumsatz.LeasingSumme
) AS PivotData
PIVOT (
  SUM(PivotData.LeasingSumme)
  FOR PivotData.Monat IN ([2020-01], [2020-02], [2020-03], [2020-04], [2020-05], [2020-06], [2020-07], [2020-08], [2020-09], [2020-10], [2020-11], [2020-12])
) AS p;