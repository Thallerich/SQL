WITH SetStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'OPETIKO'
)
SELECT OPEtiKo.EtiNr, SetStatus.StatusBez AS SetStatus, ArtikelSet.ArtikelNr AS SetArtikelNr, ArtikelSet.ArtikelBez$LAN$ AS SetArtikelBez, EinzHist.Barcode, ArtikelTeil.ArtikelNr AS TeilArtikelNr, ArtikelTeil.ArtikelBez$LAN$ AS TeilArtikelBez, OPEtiKo.VerfallDatum, OPCharge.ChargeDatum, OPCharge.ChargeNr, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaSuchCode, Vsa.Bez AS Vsa
FROM OPEtiPo, OPEtiKo, OPCharge, Artikel AS ArtikelSet, EinzTeil, EinzHist, Artikel AS ArtikelTeil, Vsa, Kunden, SetStatus
WHERE OPEtiPo.OPEtiKoID = OPEtiKo.ID
  AND OPEtiKo.OPChargeID = OPCharge.ID
  AND OPEtiKo.ArtikelID = ArtikelSet.ID
  AND OPEtiKo.Status = SetStatus.Status
  AND OPEtiPo.EinzTeilID = EinzTeil.ID
  AND EinzTeil.CurrEinzHistID = EinzHist.ID
  AND EinzHist.ArtikelID = ArtikelTeil.ID
  AND EinzHist.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPCharge.ChargeNr = $1$
  AND OPCharge.StandortID = 4535 -- Lenzing IG Micronclean
  AND OPEtiPo.EinzTeilID > 0
ORDER BY Kunden.KdNr, VsaSuchCode, OPEtiKo.EtiNr;