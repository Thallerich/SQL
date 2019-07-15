WITH TeileInProd AS (
  SELECT Prod.AusTourID AS TourenID, Prod.VsaID, Prod.ZielNrID, Prod.EinDat, Prod.AusDat, Prod.ProduktionID AS ProdStandortID, Teile.ID AS TeileID
  FROM Prod
  JOIN Teile ON Prod.TeileID = Teile.ID
  WHERE Teile.Status IN (N'N', N'Q')
    AND Prod.VsaID IN (SELECT ID FROM Vsa WHERE Vsa.StandKonID IN ($1$))
),
Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT Daten.Tour AS Liefertour, Daten.Bez AS [Liefertour-Bezeichnung], Wochentag = 
  CASE Daten.Wochentag
    WHEN 1 THEN N'Montag'
    WHEN 2 THEN N'Dienstag'
    WHEN 3 THEN N'Mittwoch'
    WHEN 4 THEN N'Donnerstag'
    WHEN 5 THEN N'Freitag'
    WHEN 6 THEN N'Samstag'
    WHEN 7 THEN N'Sonntag'
    ELSE N'WTF?'
  END
  , Standort.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS TrägerNr, Traeger.Nachname, Traeger.Vorname, Teile.Barcode, Teilestatus.StatusBez AS [Status Teil], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Daten.EinDat AS [Abhol-Datum beim Kunden], Daten.AusDat AS [geplantes Lieferdatum], ZielNr.ZielNrBez AS [letzter Scan-Ort]
FROM ZielNr
JOIN (
    SELECT DISTINCT Touren.ID, Touren.Tour, Touren.Bez, Touren.TourPrioID, Touren.Wochentag, Vsa.ID AS VsaID, Vsa.Suchcode AS VsaSuchcode, Vsa.Bez AS VsaBez, BkZiele.TeileID, BkZiele.ZielNrID, BkZiele.EinDat, BkZiele.AusDat, VSA.KundenID, Touren.SDCTour, WLot.Bez AS WLotBez, Touren.ExpeditionID AS TourExpeditionID, BKZiele.ProdStandortID, TourPrio.TourPrioBez AS TourPrioBez, Fahrt.PlanDatum AS FahrtPlanDatum
    FROM VsaTour, Vsa, TourPrio, TeileInProd AS BkZiele
    LEFT JOIN Touren ON Touren.ID = BkZiele.TourenID
    LEFT JOIN WLot ON WLot.ID = Touren.WLotID
    LEFT JOIN Fahrt ON (Fahrt.TourenID = Touren.ID AND Fahrt.UrDatum = BkZiele.AusDat)
    LEFT JOIN LsKo ON LsKo.FahrtID = Fahrt.ID
    WHERE Touren.ID = VsaTour.TourenID
      AND BkZiele.AusDat BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND Vsa.ID = VsaTour.VsaID
      AND BkZiele.VsaID = Vsa.ID
      AND Touren.TourPrioID = TourPrio.ID
) AS Daten ON Daten.ZielNrID = ZielNr.ID
JOIN Teile ON Daten.TeileID = Teile.ID
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Standort ON Daten.ProdStandortID = Standort.ID
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
WHERE ZielNr.IstKomplett = 0
  AND Daten.FahrtPlanDatum <= CAST(GETDATE() AS date);