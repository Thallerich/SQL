WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'EINZHIST')
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TRAEGER')
),
ErstAuslesen AS (
  SELECT Scans.EinzHistID, MIN(Scans.EinAusDat) AS LiefDat
  FROM Scans
  WHERE Scans.Menge = -1
  GROUP BY Scans.EinzHistID
)
SELECT Kunden.Kdnr, Kunden.Suchcode as Kunde, Holding.Holding, Traeger.Nachname, Traeger.Vorname, Traegerstatus.StatusBez AS Trägerstatus, EinzHist.Barcode, Teilestatus.StatusBez AS Teilestatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Einsatz.EinsatzBez AS Einsatzgrund, EinzHist.Anlage_ AS [Teil angelegt am], IIF(EinzHist.Status = N'E' AND TeileBPo.ID IS NOT NULL, Lief.SuchCode, NULL) AS [bestellt bei Lieferant], Lager.SuchCode AS [lieferndes Lager], EntnKo.ID AS EntnahmelistenNr, EntnKo.Anlage_ AS [Entnahmeliste angelegt am], EntnKo.DruckDatum AS [Druckdatum Entnahmeliste], [Entnahme-Datum] = (
  SELECT MAX(Scans.[DateTime])
  FROM Scans
  WHERE Scans.EinzHistID = EinzHist.ID
    AND Scans.ActionsID = 57
), EntnKo.PatchDatum AS [Patchdatum Entnahmeliste], IIF(EinzHist.IndienstDat < ISNULL(ErstAuslesen.LiefDat, N'2099-12-31'), EinzHist.IndienstDat, ErstAuslesen.LiefDat) AS [Lieferdatum zum Kunden]
FROM EinzHist
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN Einsatz ON EinzHist.EinsatzGrund = Einsatz.EinsatzGrund
JOIN Lagerart ON EinzHist.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
LEFT JOIN EntnPo ON EinzHist.EntnPoID = EntnPo.ID AND EinzHist.EntnPoID > 0 AND EinzHist.Status >= N'K'
LEFT JOIN EntnKo ON EntnPo.EntnKoID = EntnKo.ID
LEFT JOIN TeileBPo ON TeileBPo.EinzHistID = EinzHist.ID AND TeileBPo.Latest = 1
LEFT JOIN BPo ON TeileBPo.BPoID = BPo.ID
LEFT JOIN BKo ON BPo.BKoID = BKo.ID
LEFT JOIN Lief ON BKo.LiefID = Lief.ID
LEFT JOIN ErstAuslesen ON ErstAuslesen.EinzHistID = EinzHist.ID
WHERE Artikel.BereichID = 100
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND Traeger.Status != N'I'
  AND Teilestatus.ID IN ($2$)
  AND Kunden.KdGfID IN ($1$)
  AND Kunden.StandortID IN ($3$)
  AND EinzHist.Anlage_ BETWEEN $STARTDATE$ AND $ENDDATE$
ORDER BY [Entnahmeliste angelegt am];