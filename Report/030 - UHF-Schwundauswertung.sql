DECLARE @curweek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

WITH Inventurscan AS (
  SELECT OPScans.OPTeileID, MAX(OPScans.Zeitpunkt) AS Zeitpunkt
  FROM OPScans
  WHERE OPScans.ActionsID = 120
  GROUP BY OPScans.OPTeileID
),
PoolteilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'OPTEILE'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], OPTeile.Code AS Chipcode, PoolteilStatus.StatusBez AS [aktueller Status des Teils], Bereich.Bereich AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], KdArti.Vertragsartikel, RWCalc.BasisAfa AS Basisrestwert, RWCalc.RestwertInfo AS Restwert, CAST(OPTeile.LastScanTime AS date) AS [letzter Scan], Actions.ActionsBez AS [letzte Aktion], CAST(Inventurscan.Zeitpunkt AS date) AS [zuletzt inventiert], DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) AS [Tage ohne Bewegung], OPTeile.Erstwoche AS [Erster Einsatz]
FROM OPTeile
CROSS APPLY funcGetRestwertOP(OPTeile.ID, @curweek, 1) AS RWCalc
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN KdArti ON KdArti.KundenID = Kunden.ID AND KdArti.ArtikelID = Artikel.ID
JOIN Actions ON OPTeile.LastActionsID = Actions.ID
LEFT JOIN Inventurscan ON Inventurscan.OPTeileID = OPTeile.ID
JOIN PoolteilStatus ON PoolteilStatus.Status = OPTeile.Status
WHERE OPTeile.Status IN (N'Q', N'W')
  AND OPTeile.LastActionsID IN (102, 120, 136)
  AND OPTeile.RechPoID < 0
  AND OPTeile.LastScanTime < $1$
  AND Kunden.ID = $ID$;