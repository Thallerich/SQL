TRY
  DROP TABLE #TmpAUVAArtikel;
  DROP TABLE #TmpAUVATeile;
CATCH ALL END;

SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelBez$LAN$ AS ArtikelBez
INTO #TmpAUVAArtikel 
FROM Artikel 
WHERE ArtikelBez LIKE '%-7%' 
  AND Artikel.SuchCode LIKE '%AUVA%' 
  AND Artikel.Status = 'A' 
  AND EXISTS (
    SELECT OPSets.*
    FROM OPSets
    WHERE OPSets.Artikel1ID = Artikel.ID);
    
SELECT OPTeile.ID AS OPTeileID, OPTeile.ArtikelID, OPTeile.Code, OPTeile.Code2, OPTeile.Status, MAX(OPEtiPo.OPEtiKoID) AS OPEtiKoID
INTO #TmpAUVATeile
FROM OPTeile, OPEtiPo
WHERE OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpAUVAArtikel)
  AND OPTeile.ID = OPEtiPo.OPTeileID
GROUP BY OPTeileID, OPTeile.ArtikelID, OPTeile.Code, OPTeile.Code2, OPTeile.Status;

SELECT AUVATeile.Code, AUVATeile.Code2, Status.StatusBez$LAN$ AS StatusTeil, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, OPEtiKo.EtiNr AS SetSeriennummer, ArtikelSet.ArtikelNr AS SetArtikelNr, ArtikelSet.ArtikelBez$LAN$ AS SetArtikelBez, OPEtiKo.DruckZeitpunkt, OPEtiKo.PackZeitpunkt, OPCharge.Zeitpunkt AS SterilZeitpunkt, OPCharge.ChargeNr, (SELECT StatusC.StatusBez$LAN$ FROM Status AS StatusC WHERE StatusC.Status = OPCharge.Status AND StatusC.Tabelle = 'OPCHARGE') AS ChargeStatus, OPEtiKo.AusleseZeitpunkt, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaKurz, Vsa.Bez AS Vsa
FROM #TmpAUVATeile AUVATeile, Artikel, Artikel AS ArtikelSet, OPEtiKo, Vsa, Kunden, Status, OPCharge
WHERE AUVATeile.ArtikelID = Artikel.ID
  AND AUVATeile.OPEtiKoID = OPEtiKo.ID
  AND OPEtiKo.ArtikelID = ArtikelSet.ID
  AND OPEtiKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AUVATeile.Status = Status.Status
  AND Status.Tabelle = 'OPTEILE'
  AND OPEtiKo.OPChargeID = OPCharge.ID
  AND AUVATeile.Status <= 'R';
  
------------ Korrektur Teile-Status von Set-im-Set-Teilen - OPEtiKo.Status R, U behandeln ---------------------------------------------------------------------------------------------------------------
 
TRY
  DROP TABLE #SetimSet;
CATCH ALL END;

SELECT OPTeile.ID AS OPTeileID, OPTeile.Code, OPTeile.Status, OPTeile.LastScanTime, OPTeile.LastScanToKunde, OPEtiKo.ID AS OPEtiKoID, OPEtiKo.EtiNr, OPEtiKo.Status, OPEtiKo.DruckZeitpunkt, OPEtiKo.Packzeitpunkt, OPEtiKo.AusleseZeitpunkt
INTO #SetimSet
FROM OPTeile, OPEtiKo, Artikel, Bereich
WHERE OPTeile.LastOPEtiKoID = OPEtiKo.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Bereich.Bereich = 'OP'
  AND OPTeile.LastOPEtiKoID > 0
  AND OPEtiKo.Status IN ('R', 'U')
  AND OPTeile.Status = 'M'
  AND OPTeile.LastScanTime <= TIMESTAMPADD(SQL_TSI_MINUTE, 1, OPEtiKo.PackZeitpunkt);
  
UPDATE SetimSet SET SetimSet.LastScanToKunde = OPEtiKo.AusleseZeitpunkt
FROM #SetimSet AS SetimSet, OPTeile, OPEtiPo, OPEtiKo
WHERE SetimSet.EtiNr = OPTeile.Code
  AND OPEtiPo.OPTeileID = OPTeile.ID
  AND OPEtiPo.OPEtiKoID = OPEtiKo.ID;

UPDATE OPTeile SET OPTeile.Status = 'R', OPTeile.LastScanToKunde = SetimSet.LastScanToKunde, OPTeile.LastScanTime = SetimSet.LastScanToKunde
FROM #SetimSet AS SetimSet, OPTeile
WHERE SetimSet.OPTeileID = OPTeile.ID;