WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
),
VsaStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'VSA')
),
Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
)
SELECT __ABSDouble.Barcode AS [ABS-Barcode], Teile.Barcode AS [AdvanTex-Barcode], Teilestatus.StatusBez AS [Teilestatus], Teile.Eingang1 AS [letzter Eingang], Teile.Ausgang1 AS [letzter Ausgang], Teile.AbmeldDat AS [Abmelde-Datum], Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Kunden-Status], Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, VsaStatus.StatusBez AS [Vsa-Status]
FROM __ABSDouble
LEFT OUTER JOIN Teile ON Teile.Barcode = __ABSDouble.Barcode
LEFT OUTER JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
LEFT OUTER JOIN Vsa ON Teile.VsaID = Vsa.ID
LEFT OUTER JOIN Kunden ON Vsa.KundenID = Kunden.ID
LEFT OUTER JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
LEFT OUTER JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
LEFT OUTER JOIN VsaStatus ON Vsa.[Status] = VsaStatus.[Status]
LEFT OUTER JOIN Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status];