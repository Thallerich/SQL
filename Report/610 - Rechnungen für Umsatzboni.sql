SELECT RechKo.RechNr, RechKo.RechDat, RechKo.Art, RechKo.Status, RechKo.RechAdrID, RechKo.Debitor, RechKo.Name1, RechKo.Name2, RechKo.Name3, RechKo.Bruttowert, RechKo.Nettowert, RechKo.Skonto, RechKo.SkontoBetrag, RechKo.MwStBetrag, RechKo.Memo, RechPo.GPreis, Bereich.Bereich, Konten.Konto
FROM RechPo, RechKo, Kunden, Konten, Bereich
WHERE RechPo.RechKoID = RechKo.ID
  AND RechKo.KundenID = Kunden.ID
  AND RechPo.KontenID = Konten.ID
  AND RechPo.BereichID = Bereich.ID
  AND Kunden.ID IN ($ID$);