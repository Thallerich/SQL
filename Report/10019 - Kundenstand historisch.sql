WITH Kundenstand AS (
  SELECT _Umlauf.Datum, _Umlauf.KdArtiID, SUM(_Umlauf.Umlauf) AS Kundenstand
  FROM _Umlauf
  WHERE _Umlauf.Datum = DATEADD(day, ((15 - @@DATEFIRST) - DATEPART(weekday, $1$)) % 7, $1$)
  GROUP BY _Umlauf.Datum, _Umlauf.KdArtiID
)
SELECT Kundenstand.Datum AS Stichtag, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Kundenstand.Kundenstand
FROM Kundenstand
JOIN KdArti ON Kundenstand.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
WHERE Kunden.ID IN ($3$);