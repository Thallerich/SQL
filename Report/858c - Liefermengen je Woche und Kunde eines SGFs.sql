SELECT Liefermenge.Woche,
  KdGf.KurzBez AS SGF, 
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kunden.Name1 AS Adresszeile1,
  Kunden.Name2 AS Adresszeile2,
  Kunden.Name3 AS Adresszeile3,
  Standort.Bez AS Hauptstandort,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 
  Bereich.BereichBez$LAN$ AS Produktbereich, 
  Liefermenge.Liefermenge,
  KdArti.Umlauf AS Stand
FROM KdArti
LEFT JOIN (
  SELECT [Week].Woche AS Woche, LsPo.KdArtiID, SUM(LsPo.Menge) AS Liefermenge
    FROM LsPo
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID 
    JOIN [Week] ON LsKo.Datum BETWEEN [Week].VonDat AND [Week].BisDat
    WHERE LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
    GROUP BY [Week].Woche, LsPo.KdArtiID
) AS Liefermenge ON Liefermenge.KdArtiID = KdArti.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID 
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE Kunden.KdGfID IN ($2$)
  AND Kunden.StandortID IN ($3$)
  AND Kunden.Status != N'I'
  AND KdArti.Status = N'A'
GROUP BY Liefermenge.Woche, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Kunden.Name1, Kunden.Name2, Kunden.Name3, Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Bereich.BereichBez$LAN$, Liefermenge.Liefermenge, KdArti.Umlauf
ORDER BY Woche, KdNr, ArtikelNr;