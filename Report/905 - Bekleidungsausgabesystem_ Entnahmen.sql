DECLARE @von datetime = $STARTDATE$;
DECLARE @bis datetime = DATEADD(day, 1, $ENDDATE$);

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
), 
LastScan AS (
  SELECT Scans.TeileID, MAX(Scans.ID) AS ScansID
  FROM Scans
  GROUP BY Scans.TeileID
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
JOIN Actions ON Teile.LastActionsID = Actions.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
JOIN LastScan ON LastScan.TeileID = Teile.ID
JOIN Scans ON LastScan.ScansID = Scans.ID
JOIN Traeger AS EntnahmeTraeger ON Scans.LastPoolTraegerID = EntnahmeTraeger.ID
WHERE Vsa.RentomatID = $2$
  AND Traeger.RentoArtID = (SELECT RentoArt.ID FROM RentoArt WHERE RentoArt.Code = N'S')
  AND Scans.DateTime BETWEEN @von AND @bis
  AND Actions.ID = 65;   -- Aktion "Bekleidungssystem: Entnahme"