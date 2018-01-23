SET LANGUAGE N'Deutsch'; -- Sprache auf Deutsch setzen, damit Wochentag in Deutsch ausgegeben wird

SELECT Daten.Lieferdatum, Daten.Wochentag, Daten.SGF, Daten.KdNr, Daten.Kunde, Daten.ArtikelNr, Daten.Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Produktbereich, Daten.Liefermenge
FROM Bereich, ( 
 SELECT LsKo.Datum AS Lieferdatum, DATENAME(weekday, LsKo.Datum) AS Wochentag, KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.BereichID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo, LsKo, Vsa, Kunden, KdGf, KdArti, Artikel
  WHERE LsPo.LsKoID = LsKo.ID
    AND LsKo.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.KdGfID = KdGf.ID
    AND LsPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND LsKo.Datum BETWEEN $1$ AND $2$
    AND LsPo.Menge > 0
    AND Kunden.KdGfID IN ($3$)
  GROUP BY LsKo.Datum, DATENAME(day, LsKo.Datum), KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Artikel.BereichID
) AS Daten
WHERE Daten.BereichID = Bereich.ID
ORDER BY Daten.Lieferdatum, Daten.KdNr, Daten.ArtikelNr;

SET LANGUAGE N'us_english'; -- Sprache wieder auf Standard us_english zurücksetzen