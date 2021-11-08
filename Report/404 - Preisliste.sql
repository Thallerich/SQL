WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KdArti')
)
SELECT Holding.Holding, Holding.Bez AS Holdingbezeichnung, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS [Varianten-Bezeichnung], Bereich.Bereich AS Produktbereich, KdArti.WaschPreis AS [Bearbeitungs-Preis], LeasPreisWoche.LeasPreisProWo AS [Leasing-Preis], FakFreq.FakFreqBez AS Fakturafrequenz, KdArti.KundenID, KdArti.ID AS KdArtiID
FROM KdArti
CROSS APPLY dbo.advFunc_GetLeasPreisProWo(KdArti.ID) AS LeasPreisWoche
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN FakFreq ON KdBer.FakFreqID = FakFreq.ID
JOIN KdArtiStatus ON KdArti.[Status] = KdArtiStatus.[Status]
WHERE KdArti.KundenID IN ($2$)
  AND KdArtiStatus.ID IN ($3$)
ORDER BY Holding, KdNr, Artikelbezeichnung;