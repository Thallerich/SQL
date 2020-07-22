DECLARE @von datetime = $STARTDATE$;
DECLARE @bis datetime = DATEADD(day, 1, $ENDDATE$);

SELECT Scans.DateTime AS [Datum der Entnahme], EntnahmeTraeger.PersNr, EntnahmeTraeger.Traeger AS TraegerNr, EntnahmeTraeger.Nachname, EntnahmeTraeger.Vorname, Teile.Barcode, Teile.RentomatChip AS Chipcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Kunden.KdNr, Kunden.SuchCode AS Kunde, IIF(Teile.Ausdienst IS NULL, Teile.RestwertInfo, Teile.AusdRestw) AS Restwert
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Scans ON Scans.TeileID = Teile.ID
JOIN Traeger AS EntnahmeTraeger ON Scans.LastPoolTraegerID = EntnahmeTraeger.ID
WHERE Vsa.RentomatID = $2$
  AND Traeger.RentoArtID = (SELECT RentoArt.ID FROM RentoArt WHERE RentoArt.Code = N'S')
  AND Scans.DateTime BETWEEN @von AND @bis
  AND Scans.ActionsID = 65;   -- Aktion "Bekleidungssystem: Entnahme"