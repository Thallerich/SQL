DECLARE @datefrom date = '2019-09-01';
DECLARE @dateto date   = '2025-08-31';

DECLARE @Kunden TABLE (
  KdNr int
);

INSERT INTO @Kunden (KdNr)
VALUES (302290),(398076),(398666),(10003490),(10004425),(398505),(10004646),(300191),(302629),(397022),(398515),(10004461),(10006437),(398303);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ PrepareData                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #TmpErgebnis999054;

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT WegGrund.WegGrundBez AS Schrottgrund, EinzHist.Barcode, Teilestatus.StatusBez AS [Status des Teils], EinzHist.IndienstDat AS [Indienststellungs-Datum], LagerBew.Zeitpunkt AS [Lagerentnahme Zeitpunkt], ArtGru.Gruppe AS Artikelgruppe, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Vsa.VsaNr AS [VSA-Nr.], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Lagerart.LagerartBez AS Lagerart, EinzHist.ArtGroeID
INTO #TmpErgebnis999054
FROM EinzHist
JOIN EntnPo ON EinzHist.EntnPoID = EntnPo.ID
JOIN LagerBew ON LagerBew.EntnPoID = EntnPo.ID 
JOIN Lagerart ON EntnPo.LagerArtID = Lagerart.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Wae ON Kunden.RechWaeID = Wae.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
WHERE EinzHist.Entnommen = 1
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
  AND EinzHist.Archiv = 0
  AND EinzHist.EntnPoID > 0
  AND LagerBew.LgBewCodID IN (SELECT LgBewCod.ID FROM LgBewCod WHERE LgBewCod.IstEntnahme = 1)
  AND Kunden.KdNr IN (SELECT KdNr FROM @Kunden)
  AND EinzHist.IndienstDat BETWEEN @datefrom AND @dateto
  AND Lagerart.Neuwertig = 1
  AND (SELECT TOP 1 PrevEH.EinzHistTyp FROM EinzHist AS PrevEH WHERE PrevEH.EinzTeilID = EinzHist.EinzTeilID AND PrevEH.Archiv = 0 AND PrevEH.EinzHistBis <= EinzHist.EinzHistVon ORDER BY PrevEH.EinzHistBis DESC, PrevEH.ID DESC) = 2 /* nur wenn das Teil vorher im Lager war */
;

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
INSERT INTO #TmpErgebnis999054
SELECT WegGrund.WegGrundBez AS Schrottgrund, EinzHist.Barcode, Teilestatus.StatusBez AS [Status des Teils], EinzHist.IndienstDat AS [Indienststellungs-Datum], Scans.[DateTime] AS [Lagerentnahme Zeitpunkt], ArtGru.Gruppe AS Artikelgruppe, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Vsa.VsaNr AS [VSA-Nr.], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Lagerart.LagerartBez AS Lagerart, EinzHist.ArtGroeID
FROM EinzHist
JOIN Scans ON Scans.EinzHistID = EinzHist.ID AND Scans.ActionsID = 57
JOIN Bestand ON Bestand.LagerArtID = EinzHist.LagerArtID AND Bestand.ArtGroeID = EinzHist.ArtGroeID
JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Wae ON Kunden.RechWaeID = Wae.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
WHERE EinzHist.Entnommen = 1
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
  AND EinzHist.Archiv = 0
  AND EinzHist.EntnPoID = -1
  AND Kunden.ID IN (SELECT KdNr FROM @Kunden)
  AND EinzHist.IndienstDat BETWEEN @datefrom AND @dateto
  AND Lagerart.Neuwertig = 1
  AND (SELECT TOP 1 PrevEH.EinzHistTyp FROM EinzHist AS PrevEH WHERE PrevEH.EinzTeilID = EinzHist.EinzTeilID AND PrevEH.Archiv = 0 AND PrevEH.EinzHistBis <= EinzHist.EinzHistVon ORDER BY PrevEH.EinzHistBis DESC, PrevEH.ID DESC) = 2 /* nur wenn das Teil vorher im Lager war */
  AND NOT EXISTS (
    SELECT 1
    FROM #TmpErgebnis999054
    WHERE #TmpErgebnis999054.Barcode = EinzHist.Barcode
  );

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Reportdaten                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Erg.Schrottgrund, Erg.Barcode, Erg.[Status des Teils], Erg.[Indienststellungs-Datum], Erg.[Lagerentnahme Zeitpunkt], Erg.Artikelgruppe, Erg.ArtikelNr, Erg.Artikelbezeichnung, Erg.[VSA-Nr.], Erg.[VSA-Stichwort], Erg.[VSA-Bezeichnung], Erg.Produktionsstandort, Erg.KdNr, Erg.Kunde, Erg.Lagerart, g.EkPreis, Wae.IsoCode AS Währung
FROM #TmpErgebnis999054 AS Erg
JOIN (
  SELECT ArtGroe.*, IIF(ArtGroe.LiefID <> -1, ArtGroe.LiefID, Artikel.LiefID) AS ValidLiefID
  FROM (
    SELECT *
    FROM ArtGroe
    WHERE ID IN (
      SELECT DISTINCT ArtGroeID
      FROM #TmpErgebnis999054
    )
  ) AS ArtGroe
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Lief ON ArtGroe.LiefID = Lief.ID
) AS g ON Erg.ArtGroeID = g.ID
JOIN Lief ON g.ValidLiefID = Lief.ID
JOIN Wae ON Lief.WaeID = Wae.ID;