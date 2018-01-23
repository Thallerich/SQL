USE Wozabal
GO

SELECT 
  Kunden.KdNr, 
  Kunden.SuchCode AS Kunde, 
  Vsa.VsaNr, 
  Vsa.Bez AS Vsa, 
  Abteil.Abteilung AS KsSt, 
  Abteil.Bez AS Kostenstelle, 
  RechPo.Bez AS Positionsbezeichnung,
  RPoType.RPoTypeBez AS Positionstyp,
  Bereich.BereichBez AS Produktbereich,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGru.ArtGruBez AS Artikelgruppe,
  OPTeile.Code,
  OPTeile.Status,
  OPTeile.WegGrundID,
  OPTeile.WegDatum,
  OPTeile.LastScanTime,
  OPTeile.Update_
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN Vsa ON RechPo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN RPoType ON RechPo.RPoTypeID = RPoType.ID
JOIN Bereich ON RechPo.BereichID = Bereich.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON RechPo.ArtGruID = ArtGru.ID
JOIN OPTeile ON OPTeile.RechPoID = RechPo.ID
WHERE OPTeile.Status = N'Z'
  AND OPTeile.WegGrundID = 0
  AND OPTeile.RechPoID > 0
  AND OPTeile.WegDatum >= N'2017-11-09'
ORDER BY OPTeile.Update_ DESC

GO