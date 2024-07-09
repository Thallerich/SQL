SELECT EinzHist.Barcode, LagerBew.Zeitpunkt AS [Zeitpunkt Lagereingangsbuchung], Standort.Bez AS Lager, LiefLsKo.LsNr AS [LsNr Lieferant], LiefLsKo.Datum AS [Lieferschein-Datum], LiefLsKo.WeDatum AS [Wareneingangs-Datum], Lief.LiefNr AS [Lieferant-Nr.], Lief.Name1 AS Lieferant
FROM _IT84647
JOIN Einzhist ON _IT84647.Barcode LIKE EinzHist.Barcode
JOIN EinzTeil ON EinzHist.ID = EinzTeil.CurrEinzHistID
LEFT JOIN (
  SELECT LagerBew.Barcode, MAX(LagerBew.ID) AS LagerBewID
  FROM LagerBew
  JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
  JOIN LiefLsPo ON LagerBew.LiefLsPoID = LiefLsPo.ID
  JOIN LiefLsKo ON LiefLsPo.LiefLsKoID = LiefLsKo.ID
  JOIN Standort ON LiefLsKo.LagerID = Standort.ID
  WHERE LagerBew.Barcode IN (SELECT Barcode FROM _IT84647)
    AND Standort.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'SMRO')
  GROUP BY LagerBew.Barcode
) AS LastZubuch ON LastZubuch.Barcode = EinzTeil.Code
LEFT JOIN LagerBew ON LastZubuch.LagerBewID = LagerBew.ID
LEFT JOIN LiefLsPo ON LagerBew.LiefLsPoID = LiefLsPo.ID
LEFT JOIN LiefLsKo ON LiefLsPo.LiefLsKoID = LiefLsKo.ID
LEFT JOIN Lief ON LiefLsKo.LiefID = Lief.ID
LEFT JOIN Standort ON LiefLsKo.LagerID = Standort.ID
/* WHERE LagerBew.Differenz = 1
  AND LagerBew.LiefLsPoID > 0
  AND Standort.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'SMRO'); */
WHERE ISNULL(LagerBew.Differenz, 1) = 1
  AND ISNULL(LagerBew.LiefLsPoID, 1) > 0
  AND (Standort.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'SMRO') OR Standort.FirmaID IS NULL);

GO