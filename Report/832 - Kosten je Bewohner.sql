SELECT CONVERT(char(4), DATEPART(year, LsKo.Datum)) + '-' + IIF(DATEPART(month, LsKo.Datum) < 10, '0' + CONVERT(char(1), DATEPART(month, LsKo.Datum)), CONVERT(char(2), DATEPART(month, LsKo.Datum))) AS Monat, Kunden.KdNr, Traeger.PersNr AS ZimmerNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(LsPo.Menge) AS Menge, LsPo.EPreis AS Einzelpreis, SUM(LsPo.EPreis * LsPo.Menge) AS Preis
FROM LsPo, LsKo, KdArti, Artikel, Kunden, WaschPrg, Traeger
WHERE LsPo.LsKoID = LsKo.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KundenID = Kunden.ID
  AND KdArti.WaschPrgID = WaschPrg.ID
  AND LsKo.TraegerID = Traeger.ID
  AND LsKo.TraegerID > 0
  AND Traeger.Altenheim = 1
  AND WaschPrg.ChemReinigung = $3$
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND LsPo.Menge <> 0
  AND LsPo.EPreis <> 0
  AND Kunden.ID = $ID$
GROUP BY CONVERT(char(4), DATEPART(year, LsKo.Datum)) + '-' + IIF(DATEPART(month, LsKo.Datum) < 10, '0' + CONVERT(char(1), DATEPART(month, LsKo.Datum)), CONVERT(char(2), DATEPART(month, LsKo.Datum))), Kunden.KdNr, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsPo.EPreis;