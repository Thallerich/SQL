WITH Jahresumsatz AS (
  SELECT RechKo.KundenID, SUM(RechKo.Nettowert) AS Nettoumsatz
  FROM RechKo
  WHERE DATEPART(year, RechKo.RechDat) = DATEPART(year, $ENDDATE$) - 1  /* Umsatz vom Jahr vor der PE verwenden */
    AND RechKo.Status BETWEEN N'F' AND N'S'
  GROUP BY RechKo.KundenID
)
SELECT DISTINCT Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Holding, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, ABC.ABCBez AS [ABC-Klasse], PeKo.Bez AS [Bezeichnung Preiserhöhung], PeKo.WirksamDatum AS [Wirksam ab], PeKo.DurchfuehrungsDatum AS [durchgeführt am], PePo.PeProzent AS Prozentsatz, Jahresumsatz.Nettoumsatz AS [Jahresumsatz]
FROM PePo
JOIN PeKo ON PePo.PeKoID = PeKo.ID
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Jahresumsatz ON Jahresumsatz.KundenID = Kunden.ID
WHERE PeKo.WirksamDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND PePo.PeProzent != 0
  AND PeKo.Status = N'N'
  AND Firma.ID = $1$
  AND KdGf.ID IN ($2$)
  AND Holding.ID IN ($3$);