WITH SetStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'OPETIKO')
)
SELECT OPEtiKo.EtiNr, SetStatus.StatusBez AS SetStatus, ArtikelSet.ArtikelNr AS SetArtikelNr, ArtikelSet.ArtikelBez$LAN$ AS SetArtikelBez, Teile.Barcode, ArtikelTeil.ArtikelNr AS TeilArtikelNr, ArtikelTeil.ArtikelBez$LAN$ AS TeilArtikelBez, OPEtiKo.VerfallDatum, OPCharge.ChargeDatum, OPCharge.ChargeNr, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaSuchCode, Vsa.Bez AS Vsa
FROM OPEtiPo, OPEtiKo, OPCharge, Artikel AS ArtikelSet, OPTeile, Teile, Artikel AS ArtikelTeil, Vsa, Kunden, SetStatus
WHERE OPEtiPo.OPEtiKoID = OPEtiKo.ID
  AND OPEtiKo.OPChargeID = OPCharge.ID
  AND OPEtiKo.ArtikelID = ArtikelSet.ID
  AND OPEtiKo.Status = SetStatus.Status
  AND OPEtiPo.OPTeileID = OPTeile.ID
  AND Teile.OPTeileID = OPTeile.ID
  AND Teile.ArtikelID = ArtikelTeil.ID
  AND Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPCharge.ChargeNr = $1$
  AND OPCharge.StandortID = 4535 -- Lenzing IG Micronclean
  AND OPEtiPo.OPTeileID > 0
ORDER BY Kunden.KdNr, VsaSuchCode, OPEtiKo.EtiNr;