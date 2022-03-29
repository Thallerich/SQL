DECLARE @from date = $STARTDATE$;
DECLARE @to date = $ENDDATE$;

SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(IIF(LsPo.LsKoGruID IN ($2$) OR LsKo.LsKoGruID IN ($2$), ABS(LsPo.Menge), 0)) AS Reklamationsmenge, SUM(LsPo.Menge) AS Liefermenge, KdArti.WaschPreis AS Stückpreis, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Kunden, Vsa, LsKo, LsPo, KdArti, Artikel, Standort, KdGf
WHERE Kunden.ID = Vsa.KundenID
  AND Kunden.KdGfID = KdGf.ID
  AND Vsa.ID = LsKo.VsaID
  AND LsKo.ID = LsPo.LsKoID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsKo.Datum BETWEEN @from AND @to
  AND LsKo.ProduktionID = Standort.ID
  AND Standort.ID IN ($3$)
GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.WaschPreis, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode
HAVING SUM(IIF(LsPo.LsKoGruID IN ($2$) OR LsKo.LsKoGruID IN ($2$), ABS(LsPo.Menge), 0)) > 0;