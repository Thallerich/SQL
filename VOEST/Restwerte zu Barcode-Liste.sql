WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TEILE'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Vsa.Name1 AS [VSA-Adresszeile 1], Vsa.Name2 AS [VSA-Adresszeile 2], Vsa.Name3 AS [VSA-Adresszeile 3], Traeger.Traeger AS Trägernummer, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, ArtGroe.Groesse AS Größe, TraeArti.Menge AS [Max. Bestand], Teile.Barcode, CAST(IIF(Teile.Status > N'Q', 1, 0) AS bit) AS Stilllegung, Teilestatus.StatusBez AS [Status Teil], Teile.Eingang1 AS [letzter Eingang], Teile.Ausgang1 AS [letzter Ausgang], Week.Woche AS [Ersteinsatz-Woche], TeileRestwert.BasisAfa AS Basisrestwert, TeileRestwert.AlterInfo AS [Alter in Wochen], TeileRestwert.RestwertInfo AS [Restwert aktuell]
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
JOIN Teilestatus ON Teilestatus.Status = Teile.Status
JOIN Week ON DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
CROSS APPLY funcGetRestwert(Teile.ID, N'2022/09', 1) AS TeileRestwert
WHERE Teile.Barcode IN (SELECT Barcode FROM _VOESTPoolBarcode)
  AND Teile.Status BETWEEN N'Q' AND N'W'
  AND Teile.Einzug IS NULL;