DROP TABLE IF EXISTS #LeasingUmsatz;
GO

SELECT KdArti.ArtikelID, StandBer.ProduktionID, SUM((AbtKdArW.EPreis * AbtKdArW.Menge) * (1 - RechPo.RabattProz / 100)) AS Umsatz
INTO #LeasingUmsatz
FROM AbtKdArW
JOIN KdArti ON AbtKdArW.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN RechPo ON AbtKdArW.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
WHERE Wochen.Monat1 BETWEEN N'2024-01' AND N'2024-12'
  AND RechKo.[Status] < N'X'
  AND RechKo.[Status] >= N'N'
GROUP BY KdArti.ArtikelID, StandBer.ProduktionID;

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Bereich.BereichBez AS Produktbereich, Standort.Bez AS Produktion, SUM(LsPo.Menge) AS Liefermenge, SUM(LsPo.Menge * LsPo.EPreis) AS [Umsatz Bearbeitung netto], SUM(ISNULL(#LeasingUmsatz.Umsatz, 0)) AS [Umsatz Leasing netto]
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Standort ON LsPo.ProduktionID = Standort.ID
LEFT JOIN #LeasingUmsatz ON #LeasingUmsatz.ArtikelID = Artikel.ID AND #LeasingUmsatz.ProduktionID = Standort.ID
WHERE LsKo.Datum >= N'2024-01-01'
  AND LsKo.Datum <= N'2024-01-31'
  AND LsKo.InternKalkFix = 1
  AND LsKo.SentToSAP = 1
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Bereich.BereichBez, Standort.Bez;

GO