USE Wozabal
GO

SELECT Bereich.BereichBez AS Bereich, RPoType.RPoTypeBez AS Typ, Branche.BrancheBez AS Branche, Firma.Bez AS Firma, KdGf.Bez AS SGF, MwSt.Bez AS MwSt, RKoType.Bez AS RechKoTyp, RechKo.RechDat, RechKo.RechNr, Kunden.KdNr, RechKo.FibuExpID
FROM RechPo, RechKo, Bereich, RPoType, Kunden, Firma, MwSt, RKoType, KdGf, Branche
WHERE RechPo.RechKoID = RechKo.ID
  AND RechPo.BereichID = Bereich.ID
  AND RechPo.RPoTypeID = RPoType.ID
  AND RechKo.KundenID = Kunden.ID
  AND Kunden.FirmaID = Firma.ID
  AND Kunden.BrancheID = Branche.ID
  AND RechPo.MwStID = MwSt.ID
  AND RechKo.RKoTypeID = RKoType.ID
  AND Kunden.KdGfID = KdGf.ID
  AND (RechPo.KontenID < 0 OR RechPo.KontenID = 564)
  AND (RechKo.RechDat > '2016-03-31' OR RechKo.RechNr < 0)
  AND RechKo.FibuExpID < 0
  --AND RechKo.RechNr = 142579
  AND Firma.SuchCode <> N'STX'  -- Schweighofer Textilservice GmbH macht keine FIBU-Übergaben!
GROUP BY Bereich.BereichBez, RPoType.RPoTypeBez, Branche.BrancheBez, Firma.Bez, KdGf.Bez, MwSt.Bez, RKoType.Bez, RechKo.RechDat, RechKo.RechNr, Kunden.KdNr, RechKo.FibuExpID
ORDER BY Firma, Bereich, Typ;

/*;
SELECT RechPo.*
FROM RechPo, RechKo
WHERE RechPo.RechKoID = RechKo.ID
  AND RechPo.KontenID < 0
  AND RechKo.RechNr = 951273;
  
UPDATE RechPo SET KontenID = (SELECT ID FROM Konten WHERE Konto = '602107'), KsSt = (SELECT KsSt FROM Konten WHERE Konto = '602107')
WHERE RechPo.ID IN (8904688);
*/