/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: LSTeile                                                                                                         ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-06-26                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Traeger.Traeger, IIF(Traeger.Vorname IS NULL, N'', Traeger.Vorname + N' ') + ISNULL(Traeger.Nachname, N'') AS TraegerName, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Teile.Barcode, CAST(Scans.[DateTime] AS date) AS Scandatum, Traeger.SchrankInfo
FROM Scans
JOIN Teile ON Scans.TeileID = Teile.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
WHERE LsKo.LsNr = $1$
ORDER BY Traeger, TraegerName, ArtikelNr, Groesse, Barcode;