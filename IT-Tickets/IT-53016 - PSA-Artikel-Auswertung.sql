DECLARE @lastSunday date = CAST(DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6) AS date);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, _Umlauf.Umlauf AS Umlaufmenge
FROM _Umlauf
JOIN ArtGroe ON _Umlauf.ArtGroeID = ArtGroe.ID
JOIN Artikel ON _Umlauf.ArtikelID = Artikel.ID
JOIN KdArti ON _Umlauf.KdArtiID = KdArti.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
WHERE _Umlauf.Datum = @lastSunday;