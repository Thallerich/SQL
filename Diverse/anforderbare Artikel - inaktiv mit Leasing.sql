WITH VsaAnfStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VSAANF'
),
Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status Kunde], [Zone].ZonenCode AS Vertriebszone, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.LeasPreis AS [Leasing-Preis], VsaAnf.Bestand AS Vertragsbestand, VsaAnfStatus.StatusBez AS [Status anforderbarer Artikel]
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN VsaAnfStatus ON VsaAnf.Status = VsaAnfStatus.Status
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
WHERE VsaAnf.Bestand != 0
  AND KdArti.LeasPreis != 0
  AND VsaAnf.Status IN (N'E', N'I')
  AND Vsa.Status != N'I'
ORDER BY Vertriebszone, KdNr, ArtikelNr;