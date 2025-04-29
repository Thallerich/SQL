DROP TABLE IF EXISTS #LeasingUmsatz;
GO

SELECT KdArti.ArtikelID, StandBer.ProduktionID, SUM((AbtKdArW.EPreis * AbtKdArW.Menge) * (1 - RechPo.RabattProz / 100)) AS Umsatz
INTO #LeasingUmsatz
FROM AbtKdArW
JOIN KdArti ON AbtKdArW.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN RechPo ON AbtKdArW.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
WHERE Wochen.Monat1 BETWEEN N'2024-04' AND N'2025-03'
  AND RechKo.[Status] < N'X'
  AND RechKo.[Status] >= N'N'
  AND Kunden.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'FA14')
GROUP BY KdArti.ArtikelID, StandBer.ProduktionID;

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Bereich.BereichBez AS Produktbereich, ArtGru.ArtGruBez AS Artikelgruppe, CAST(IIF(UPPER(Artikel.ArtikelBez) LIKE '%HIVIS%', 1, 0) AS bit) AS HIVIS, CAST(IIF(EXISTS(SELECT Normen.* FROM ArtiNorm JOIN Normen ON ArtiNorm.NormenID = Normen.ID WHERE ArtiNorm.ArtikelID = Artikel.ID AND UPPER(Normen.NormenBez) LIKE '"PSA"%'), 1, 0) AS bit) AS PSA, Standort.Bez AS Produktion, SUM(LsPo.Menge) AS Liefermenge, SUM(LsPo.Menge * LsPo.EPreis) AS [Umsatz Bearbeitung netto], SUM(ISNULL(#LeasingUmsatz.Umsatz, 0)) AS [Umsatz Leasing netto], SUM(LsPo.InternKalkPreis * LsPo.Menge) AS [bezahlter Waschlohn]
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Standort ON LsPo.ProduktionID = Standort.ID
LEFT JOIN #LeasingUmsatz ON #LeasingUmsatz.ArtikelID = Artikel.ID AND #LeasingUmsatz.ProduktionID = Standort.ID
WHERE LsKo.Datum >= N'2024-04-01'
  AND LsKo.Datum <= N'2025-03-31'
  AND LsKo.InternKalkFix = 1
  AND LsKo.SentToSAP = 1
  AND Kunden.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'FA14')
GROUP BY Artikel.ID, Artikel.ArtikelNr, Artikel.ArtikelBez, Bereich.BereichBez, ArtGru.ArtGruBez, CAST(IIF(UPPER(Artikel.ArtikelBez) LIKE '%HIVIS%', 1, 0) AS bit), Standort.Bez;

GO