SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, __sizechange.Aenderung, LEFT(__sizechange.Groesse, CHARINDEX(N'/', __sizechange.Groesse, 1) - 1) + N'/' + RIGHT(REPLICATE(N'0', 3) + RTRIM(__sizechange.Aenderung), 3) AS NewSize, NewArtGroe.ID AS NewArtGroeID
FROM __sizechange
JOIN Artikel ON __sizechange.ArtikelNr = Artikel.ArtikelNr
JOIN ArtGroe ON __sizechange.Groesse = ArtGroe.Groesse AND Artikel.ID = ArtGroe.ArtikelID
LEFT JOIN ArtGroe AS NewArtGroe ON LEFT(__sizechange.Groesse, CHARINDEX(N'/', __sizechange.Groesse, 1) - 1) + N'/' + RIGHT(REPLICATE(N'0', 3) + RTRIM(__sizechange.Aenderung), 3) = NewArtGroe.Groesse AND Artikel.ID = NewArtGroe.ArtikelID
JOIN TraeArti ON ArtGroe.ID = TraeArti.ArtGroeID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID AND __sizechange.TraegerNr = Traeger.Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID AND __sizechange.VsaNr = Vsa.VsaNr
JOIN Kunden ON Vsa.KundenID = Kunden.ID AND __sizechange.KdNr = Kunden.KdNr
WHERE CHARINDEX(N'/', __sizechange.Groesse) > 0
  AND NewArtGroe.ID IS NULL;