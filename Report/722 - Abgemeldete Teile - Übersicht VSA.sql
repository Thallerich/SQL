WITH TeilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT EinzHist.Barcode, TeilStatus.StatusBez AS [Status des Teils], Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa
FROM EinzHist, EinzTeil, Traeger, Vsa, Kunden, Artikel, ArtGroe, TeilStatus
WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
  AND EinzHist.TraegerID = Traeger.ID
	AND EinzHist.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND EinzHist.ArtikelID = Artikel.ID
	AND EinzHist.ArtGroeID = ArtGroe.ID
	AND EinzHist.Status = TeilStatus.Status
	AND Vsa.ID = $ID$
	AND EinzHist.Status IN ('S', 'T', 'U', 'V', 'W')
ORDER BY Traeger.Traeger, Artikel.ArtikelNr, ArtGroe.Groesse;