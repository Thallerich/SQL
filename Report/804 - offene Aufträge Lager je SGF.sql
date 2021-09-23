WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TRAEGER')
),
ErstAuslesen AS (
  SELECT Scans.TeileID, MIN(Scans.EinAusDat) AS LiefDat
  FROM Scans
  WHERE Scans.Menge = -1
  GROUP BY Scans.TeileID
)
SELECT Kunden.Kdnr, Kunden.Suchcode as Kunde, Holding.Holding, Traeger.Nachname, Traeger.Vorname, Traegerstatus.StatusBez AS Trägerstatus, Teile.Barcode, Teilestatus.StatusBez AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Einsatz.EinsatzBez AS Einsatzgrund, Teile.Anlage_ AS [Teil angelegt am], IIF(Teile.Status = N'E' AND TeileBPo.ID IS NOT NULL, Lief.SuchCode, NULL) AS [bestellt bei Lieferant], Lager.SuchCode AS [lieferndes Lager], EntnKo.ID AS EntnahmelistenNr, EntnKo.Anlage_ AS [Entnahmeliste angelegt am], EntnKo.DruckDatum AS [Druckdatum Entnahmeliste], [Entnahme-Datum] = (
  SELECT MAX(Scans.[DateTime])
  FROM Scans
  WHERE Scans.TeileID = Teile.ID
    AND Scans.ActionsID = 57
), EntnKo.PatchDatum AS [Patchdatum Entnahmeliste], IIF(Teile.IndienstDat < ISNULL(ErstAuslesen.LiefDat, N'2099-12-31'), Teile.IndienstDat, ErstAuslesen.LiefDat) AS [Lieferdatum zum Kunden]
FROM Teile
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Teilestatus ON Teile.[Status] = Teilestatus.[Status]
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN Einsatz ON Teile.EinsatzGrund = Einsatz.EinsatzGrund
JOIN Lagerart ON Teile.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
LEFT JOIN EntnPo ON Teile.EntnPoID = EntnPo.ID AND Teile.EntnPoID > 0 AND Teile.Status >= N'K'
LEFT JOIN EntnKo ON EntnPo.EntnKoID = EntnKo.ID
LEFT JOIN TeileBPo ON TeileBPo.TeileID = Teile.ID AND TeileBPo.Latest = 1
LEFT JOIN BPo ON TeileBPo.BPoID = BPo.ID
LEFT JOIN BKo ON BPo.BKoID = BKo.ID
LEFT JOIN Lief ON BKo.LiefID = Lief.ID
LEFT JOIN ErstAuslesen ON ErstAuslesen.TeileID = Teile.ID
WHERE Artikel.BereichID = 100
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND Traeger.Status != N'I'
  AND Teilestatus.ID IN ($2$)
  AND Kunden.KdGfID IN ($1$)
  AND Kunden.StandortID IN ($3$)
  AND Teile.Anlage_ BETWEEN $STARTDATE$ AND $ENDDATE$
ORDER BY [Entnahmeliste angelegt am];