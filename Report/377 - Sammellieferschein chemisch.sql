SELECT Kunden.KdNr, Kunden.ID AS KundenID, Vsa.ID AS VsaID, LsKo.Datum, LsKo.TraegerID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, SUM(LsPo.Menge) AS Anzahl
FROM LsPo, LsKo, Vsa, Kunden, KdArti, Artikel, WaschPrg
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.WaschPrgID = WaschPrg.ID
  AND WaschPrg.ChemReinigung = 1
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND LsKo.TraegerID > 0
  AND Kunden.ID = $ID$
GROUP BY Kunden.KdNr, Kunden.ID, Vsa.ID, LsKo.Datum, LsKo.TraegerID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$;