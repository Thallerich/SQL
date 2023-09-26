WITH TeilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS Vsa, Vsa.Bez AS VsaBezeichnung, Traeger.Vorname, Traeger.Nachname, EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, TeilStatus.StatusBez AS [Status des Teils]
FROM Kunden, Vsa, Traeger, EinzHist, EinzTeil, Artikel, TeilStatus, ArtGru
WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
  AND EinzHist.TraegerID = Traeger.ID
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND EinzHist.ArtikelID = Artikel.ID
	AND Artikel.ArtGruID = ArtGru.ID
	AND EinzHist.Status = TeilStatus.Status
	AND ArtGru.Sack = 1	-- Nur Wäschesäcke !
	AND Kunden.ID IN ($ID$)
ORDER BY KdNr, Vsa, Nachname, ArtikelNr;