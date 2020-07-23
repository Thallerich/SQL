DECLARE @von datetime = $STARTDATE$;
DECLARE @bis datetime = DATEADD(day, 1, $ENDDATE$);

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT Scans.DateTime AS [Datum der Entnahme], EntnahmeTraeger.PersNr, EntnahmeTraeger.Traeger AS TraegerNr, EntnahmeTraeger.Nachname, EntnahmeTraeger.Vorname, Teile.Barcode, Teile.RentomatChip AS Chipcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Kunden.KdNr, Kunden.SuchCode AS Kunde, IIF(Teile.Ausdienst IS NULL, Teile.RestwertInfo, Teile.AusdRestw) AS Restwert, Teilestatus.StatusBez AS [aktueller Status des Teils], Actions.ActionsBez AS [letzte Aktion des Teils]
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
JOIN Actions ON Teile.LastActionsID = Actions.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
WHERE Vsa.RentomatID = $2$
  AND Traeger.RentoArtID = (SELECT RentoArt.ID FROM RentoArt WHERE RentoArt.Code = N'S')
  AND Scans.DateTime BETWEEN @von AND @bis
  AND Scans.ActionsID = 65;   -- Aktion "Bekleidungssystem: Entnahme"