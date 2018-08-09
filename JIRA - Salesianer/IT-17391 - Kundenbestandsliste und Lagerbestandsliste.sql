SELECT Firma.Bez AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.Suchcode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, SUM(TraeArti.Menge) AS Umlaufmenge
FROM TraeArti
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
WHERE Traeger.Altenheim = 0
  AND TraeArti.Menge <> 0
  AND Kunden.Status = N'A'
  AND Firma.SuchCode = N'UKLU'
GROUP BY Firma.Bez, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse
ORDER BY Firma, Geschäftsbereich, KdNr, ArtikelNr;

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, SUM(Bestand.Bestand) AS Lagerbestand, IIF(LagerArt.Neuwertig = 1, N'Neuware', N'Gebrauchtware') AS Art
FROM Bestand
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
WHERE Bestand.Bestand <> 0
  AND Standort.SuchCode = N'UKLU'
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, IIF(LagerArt.Neuwertig = 1, N'Neuware', N'Gebrauchtware')
ORDER BY ArtikelNr, Art;