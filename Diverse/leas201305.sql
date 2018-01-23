SELECT Firma.SuchCode, Firma.Bez, Konten.Konto, Konten.KsSt, Konten.Bez, KdGf.KurzBez AS SGF, Standort.Bez AS Produktionsort, SUM(AbtKdArW.WoPa) AS Umsatz
FROM AbtKdArW, Wochen, Abteil, Vsa, Kunden, Firma, RechPo, Konten, StandKon, StandBer, Standort, KdGf, KdArti, KdBer
WHERE Abteil.ID = AbtKdArW.AbteilID
  AND Wochen.ID = AbtKdArW.WochenID
  AND AbtKdArW.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.FirmaID = Firma.ID
  AND AbtKdArW.RechPoID = RechPo.ID
  AND RechPo.KontenID = Konten.ID
  AND Vsa.StandKonID = StandKon.ID
  AND AbtKdArW.KdArtiID = KdArti.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = StandBer.BereichID
  AND StandBer.StandKonID = StandKon.ID
  AND StandBer.ProduktionID = Standort.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Wochen.Woche = '2013/05'
GROUP BY Firma.SuchCode, Firma.Bez, Konten.Konto, Konten.KsSt, Konten.Bez, SGF, Produktionsort;