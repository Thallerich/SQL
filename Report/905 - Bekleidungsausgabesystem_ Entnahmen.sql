DECLARE @von datetime = $STARTDATE$;
DECLARE @bis datetime = DATEADD(day, 1, $ENDDATE$);

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
), 
Entnahmen AS (
  SELECT Scans.TeileID, Scans.[DateTime], Scans.LastPoolTraegerID
  FROM Scans
  WHERE Scans.[DateTime] BETWEEN @von AND @bis
    AND Scans.ActionsID = 65
)
SELECT Entnahmen.DateTime AS [Datum der Entnahme], EntnahmeTraeger.PersNr, EntnahmeTraeger.Traeger AS TraegerNr, EntnahmeTraeger.Nachname, EntnahmeTraeger.Vorname, Abteil.Abteilung AS KsSt, Abteil.Bez AS Kostenstelle, Teile.Barcode, Teile.RentomatChip AS Chipcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Kunden.KdNr, Kunden.SuchCode AS Kunde, IIF(Teile.Ausdienst IS NULL, Teile.RestwertInfo, Teile.AusdRestw) AS Restwert, Teilestatus.StatusBez AS [aktueller Status des Teils], Actions.ActionsBez$LAN$ AS [letzte Aktion des Teils]
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
JOIN Entnahmen ON Entnahmen.TeileID = Teile.ID
JOIN Traeger AS EntnahmeTraeger ON Entnahmen.LastPoolTraegerID = EntnahmeTraeger.ID
JOIN Abteil ON EntnahmeTraeger.AbteilID = Abteil.ID
JOIN Actions ON Teile.LastActionsID = Actions.ID
WHERE Vsa.RentomatID = $2$
  AND Traeger.RentoArtID IN (SELECT RentoArt.ID FROM RentoArt WHERE RentoArt.Code IN (N'S', N'T'))
ORDER BY Barcode ASC;