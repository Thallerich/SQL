WITH BewTeile AS (
  SELECT TOP 1000 Teile.Barcode, RIGHT(Teile.Barcode, 8) AS [Datamatrix], Teile.Status, Teile.Eingang1, Teile.Ausgang1
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  WHERE Teile.AltenheimModus = 1
    AND Firma.SuchCode = N'WOMI'
    AND LEN(Teile.Barcode) = 11
    AND LEFT(Teile.Barcode, 3) = N'999'
),
BKStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
),
BewStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT Teile.Barcode AS [BK-Barcode], Teile.Status AS [BK-Status], BKstatus.StatusBez AS [BK-Status-Bezeichnung], Teile.Eingang1 AS [BK - Letzter Eingang], Teile.Ausgang1 AS [BK - Letzter Ausgang], BewTeile.Barcode AS [BEW-Barcode], BewTeile.Status AS [BEW-Status], BewStatus.StatusBez AS [BEW-Status-Bezeichnung], BewTeile.Eingang1 AS [BEW - Letzter Eingang], BewTeile.Ausgang1 AS [BEW - Letzter Ausgang]
FROM Teile
JOIN BewTeile ON Teile.Barcode = BewTeile.Datamatrix
JOIN BKStatus ON Teile.Status = BKStatus.Status
JOIN BewStatus ON BewTeile.[Status] = BewStatus.[Status];