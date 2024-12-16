SELECT EinzTeil.ID AS EinzTeilID, EinzTeil.Code AS Chipcode, Teilstatus.StatusBez AS [Status Teil], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], Bereich.BereichBez$LAN$ AS Produktbereich, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe, COALESCE(IIF(ArtiStan.Packmenge <= 0, NULL, ArtiStan.Packmenge), Artikel.Packmenge) AS Packmenge, ServType.ServTypeBez$LAN$ AS [Service-Art], StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration], Kunden.SuchCode + N' (' + FORMAT(Kunden.KdNr, N'N0') + ')' AS [lettzer Kunde], Vsa.Bez + N'(' + FORMAT(Vsa.VsaNr, N'N0') + ')' AS [letzte VSA], Actions.ActionsBez$LAN$ AS [lettze Aktion]
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Actions ON EinzTeil.LastActionsID = Actions.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ServType ON Vsa.ServTypeID = ServType.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'ARTIKEL'
) AS Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZTEIL'
) AS Teilstatus ON EinzTeil.[Status] = Teilstatus.[Status]
JOIN StandBer ON StandBer.StandKonID = StandKon.ID AND StandBer.BereichID = Bereich.ID
LEFT JOIN ArtiStan ON ArtiStan.ArtikelID = Artikel.ID AND ArtiStan.StandortID = StandBer.ProduktionID
WHERE Artikel.ID IN ($1$)
  AND Vsa.StandKonID IN ($2$)
  AND Vsa.ServTypeID IN ($3$)
  AND EinzHist.PoolFkt = 1
  AND EinzHist.EinzHistTyp = 1;