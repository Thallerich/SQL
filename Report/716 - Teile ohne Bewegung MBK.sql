/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile_oB_Summe                                                                                                            ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(EinzHist.ID) AS Anzahl
FROM EinzHist, EinzTeil, Artikel, Vsa, Kunden
WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
  AND EinzHist.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND EinzHist.ArtikelID = Artikel.ID
	AND Kunden.ID = $ID$
	AND (EinzHist.Eingang1 IS NULL OR EinzHist.Eingang1 <= $1$)
	AND (EinzHist.Ausgang1 IS NULL OR EinzHist.Ausgang1 <= $1$)
	AND EinzHist.Status = 'Q'
  AND EinzHist.PoolFkt = 0
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Artikel.ArtikelNr;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile_ohne_Bewegung                                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, EinzHist.Barcode, EinzHist.Eingang1, EinzHist.Ausgang1
FROM Kunden, Vsa, Traeger, EinzHist, EinzTeil, Artikel, ArtGroe
WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
  AND EinzHist.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND EinzHist.TraegerID = Traeger.ID
	AND EinzHist.ArtikelID = Artikel.ID
	AND EinzHist.ArtGroeID = ArtGroe.ID
	AND Kunden.ID = $ID$
	AND (EinzHist.Eingang1 IS NULL OR EinzHist.Eingang1 <= $1$)
	AND (EinzHist.Ausgang1 IS NULL OR EinzHist.Ausgang1 <= $1$)
	AND EinzHist.Status = 'Q'
  AND EinzHist.PoolFkt = 0
ORDER BY Kunden.KdNr, Traeger.Traeger, Artikel.ArtikelNr;