WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Vsa.RentomatID, Traeger.Traeger AS [Träger-Nr], Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Barcode, EinzHist.RentomatChip AS Chipcode, Teilestatus.StatusBez AS [aktueller Status]
FROM EinzHist
JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
WHERE EinzHist.RentomatChip IN (
    SELECT TagNumber COLLATE Latin1_General_CS_AS
    FROM _DeisterTeile
    WHERE ArticleGroupID = 0
  )
  AND EXISTS (
    SELECT *
    FROM _DeisterArtikel
    WHERE CONCAT(Artikel.ArtikelNr, N'|', ArtGroe.Groesse) = _DeisterArtikel.ImportID COLLATE Latin1_General_CS_AS
  )
  AND Artikel.ArtikelNr = N'P956';

GO