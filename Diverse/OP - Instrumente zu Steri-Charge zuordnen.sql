UPDATE OPEtiKo SET Status = N'M', OPChargeID = (SELECT OPCharge.ID FROM OPCharge JOIN OPSteri ON OPCharge.OPSteriID = OPSteri.ID WHERE OPCharge.ChargeNr = 1858 AND OPSteri.SteriNr = 42)
--SELECT * FROM OPEtiKo
WHERE OPEtiKo.AnfPoID IN (
  SELECT AnfPo.ID
  FROM AnfPo
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  WHERE AnfKo.AuftragsNr IN (N'19251292', N'19251290')
)
AND OPEtiKo.Status = N'J';

UPDATE OPCharge SET Status = N'A', OPSteriChargeID = -1 WHERE ID = 1361653;