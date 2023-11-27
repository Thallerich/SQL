DROP TABLE IF EXISTS #TmpErgebnis999054;

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT WegGrund.WegGrundBez$LAN$ AS Schrottgrund, EinzHist.Barcode, Teilestatus.StatusBez AS [Status des Teils], EinzHist.IndienstDat AS [Indienststellungs-Datum], LagerBew.Zeitpunkt AS [Lagerentnahme Zeitpunkt], ArtGru.Gruppe AS Artikelgruppe, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Vsa.VsaNr AS [VSA-Nr.], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Produktion.Bez AS Produktionsstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Lagerart.LagerartBez$LAN$ AS Lagerart,
  ArGrLiefID = COALESCE(
    (
      SELECT TOP 1 ArGrLief.ID
      FROM ArGrLief
      JOIN ArtiLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
      JOIN Artikel ON ArtiLief.ArtikelID = Artikel.ID
      LEFT JOIN LiefPrio ArtGroePrio ON ArtiLief.StandortID = ArtGroePrio.StandortID AND ArtiLief.ArtikelID = ArtGroePrio.ArtikelID AND ArtGroePrio.LiefID = ArtiLief.LiefID AND ArtGroePrio.ArtGroeID = ArGrLief.ArtGroeID
      LEFT JOIN LiefPrio ArtikelPrio ON ArtiLief.StandortID = ArtikelPrio.StandortID AND ArtiLief.ArtikelID = ArtikelPrio.ArtikelID AND ArtikelPrio.LiefID = ArtiLief.LiefID AND ArtikelPrio.ArtGroeID = - 1
      JOIN Lief ON ArtiLief.LiefID = Lief.ID
      WHERE ArGrLief.ArtGroeID = EinzHist.ArtGroeID
        AND ArGrLief.VonDatum <= CAST(LagerBew.Zeitpunkt AS date)
        AND ArtiLief.StandortID = 5313
        AND IIF(COALESCE(ArtGroePrio.ID, ArtikelPrio.ID, 0) > 0, CAST(1 AS bit), CAST(0 AS bit)) = 1
      ORDER BY ArGrLief.VonDatum DESC
    ),
    (
      SELECT TOP 1 ArGrLief.ID
      FROM ArGrLief
      JOIN ArtiLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
      JOIN Artikel ON ArtiLief.ArtikelID = Artikel.ID
      LEFT JOIN LiefPrio ArtGroePrio ON ArtiLief.StandortID = ArtGroePrio.StandortID AND ArtiLief.ArtikelID = ArtGroePrio.ArtikelID AND ArtGroePrio.LiefID = ArtiLief.LiefID AND ArtGroePrio.ArtGroeID = ArGrLief.ArtGroeID
      LEFT JOIN LiefPrio ArtikelPrio ON ArtiLief.StandortID = ArtikelPrio.StandortID AND ArtiLief.ArtikelID = ArtikelPrio.ArtikelID AND ArtikelPrio.LiefID = ArtiLief.LiefID AND ArtikelPrio.ArtGroeID = - 1
      JOIN Lief ON ArtiLief.LiefID = Lief.ID
      WHERE ArGrLief.ArtGroeID = EinzHist.ArtGroeID
        AND ArGrLief.VonDatum <= CAST(LagerBew.Zeitpunkt AS date)
        AND IIF(ArtiLief.LiefID = Artikel.LiefID AND ArtiLief.StandortID = -1, CAST(1 AS bit), CAST(0 AS bit)) = 1
      ORDER BY ArGrLief.VonDatum DESC
    ), -1)
INTO #TmpErgebnis999054
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
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
  AND EinzHist.EntnPoID > 0
  AND Kunden.ID IN ($3$)
  AND EinzHist.IndienstDat BETWEEN $STARTDATE$ AND $ENDDATE$;

SELECT Erg.Schrottgrund, Erg.Barcode, Erg.[Status des Teils], Erg.[Indienststellungs-Datum], Erg.[Lagerentnahme Zeitpunkt], Erg.Artikelgruppe, Erg.ArtikelNr, Erg.Artikelbezeichnung, Erg.[VSA-Nr.], Erg.[VSA-Stichwort], Erg.[VSA-Bezeichnung], Erg.Produktionsstandort, Erg.KdNr, Erg.Kunde, Erg.Lagerart, ArGrLief.EkPreis, Lief.WaeID AS EKPreis_WaeID, Wae.IsoCode AS Währung
FROM #TmpErgebnis999054 AS Erg
JOIN ArGrLief ON Erg.ArGrLiefID = ArGrLief.ID
JOIN ArtiLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
JOIN Lief ON ArtiLief.LiefID = Lief.ID
JOIN Wae ON Lief.WaeID = Wae.ID;