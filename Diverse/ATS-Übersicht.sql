SELECT Kunden.KdNr, Vsa.Bez AS VsaBezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez, Strumpf.Barcode, Status.Bez AS Status, Strumpf.Ruecklauf AS Waeschen, MIN(StrHist.Zeitpunkt) AS ErsterScan, MAX(StrHist.Zeitpunkt) AS LetzterScan, IIF(WegGrund.ID = -1, '', WegGrund.Bez) AS Ausscheidungsgrund
FROM Strumpf, StrHist, Status, Vsa, Kunden, WegGrund, KdArti, ViewArtikel Artikel
WHERE StrHist.StrumpfID = Strumpf.ID
	AND Strumpf.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
        AND Strumpf.WegGrundID = WegGrund.ID
        AND Strumpf.KdArtiID = KdArti.ID
        AND KdArti.ArtikelID = Artikel.ID
        AND Artikel.LanguageID = $LANGUAGE$
	AND Strumpf.Status = Status.Status
	AND Status.Tabelle = 'STRHIST'
	AND Kunden.KdNr = 20156
GROUP BY Kunden.KdNr, Vsa.SuchCode, VsaBezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez, Strumpf.Barcode, Status, Waeschen, Ausscheidungsgrund
ORDER BY Kunden.KdNr, VsaBezeichnung, Artikel.ArtikelNr, Status;