DECLARE @LastSunday date = (SELECT DATEADD(day, 1 - DATEPART(weekday, GETDATE()), CAST(GETDATE() AS date)));

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Firma.SuchCode AS Firma, [Zone].ZonenCode AS Vertriebszone, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Bereich.BereichBez AS Produktbereich, ABC.ABCBez AS [ABC-Klasse], SUM(_Umlauf.Umlauf) AS Umlaufmenge
FROM _Umlauf
JOIN Vsa ON _Umlauf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Artikel ON _Umlauf.ArtikelID = Artikel.ID
JOIN ArtGroe ON _Umlauf.ArtGroeID = ArtGroe.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ABC ON Artikel.AbcID = ABC.ID
WHERE Datum = @LastSunday
  AND Firma.SuchCode = N'FA14'
  AND Kunden.Status = N'A'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Firma.SuchCode, [Zone].ZonenCode, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Bereich.BereichBez, ABC.ABCBez;

GO

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Firma.SuchCode AS Firma, [Zone].ZonenCode AS Vertriebszone, Produktion.SuchCode AS [Produktion-Kürzel], Produktion.Bez AS [Produktions-Standort], Expedition.SuchCode AS [Expedition-Kürzel], Expedition.Bez AS [Expeditions-Standort], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Bereich.BereichBez AS Produktbereich, ABC.ABCBez AS [ABC-Klasse], SUM(LsPo.Menge) AS Liefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ABC ON Artikel.AbcID = ABC.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Standort AS Produktion ON LsPo.ProduktionID = Produktion.ID
JOIN Standort AS Expedition ON Fahrt.ExpeditionID = Expedition.ID
WHERE LsKo.Datum BETWEEN N'2020-11-01' AND N'2021-10-31'
  AND Firma.SuchCode = N'FA14'
  AND Produktion.ID > 0
  AND Expedition.ID > 0
GROUP BY Kunden.KdNr, Kunden.SuchCode, Firma.SuchCode, [Zone].ZonenCode, Produktion.SuchCode, Produktion.Bez, Expedition.SuchCode, Expedition.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, Bereich.BereichBez, ABC.ABCBez;

GO