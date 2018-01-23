-- Table Rechnungsdaten
DROP TABLE IF EXISTS CPSalesDemo.dbo.Rechnungsdaten;

SELECT Kunden.Debitor AS Kostentraeger, RTRIM(Kunden.Name1) + IIF(Kunden.Name2 IS NOT NULL, ' ' + RTRIM(Kunden.Name2), '') AS KTrName, KdGf.KurzBez AS SGF, Holding.Bez AS Holding, IIF(ISNUMERIC(AdrGrp.Nr) = 0, AdrGrp.Nr, KdGf.KurzBez) AS Kundengruppe, ABC.Abc AS Kundenart, Mitarbei.Initialen AS Betreuer, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGru.ArtGruBez AS Artikelgruppe, Konten.Konto AS Erloeskonto, '' AS Erloesart, RechPo.KsSt AS Kostenstelle, Standort.Bez AS Produktion, YEAR(LsKo.Datum) AS Jahr, MONTH(LsKo.Datum) AS Monat, SUM(RechPo.Menge) AS RgMenge, SUM(LsPo.Menge) AS LsMenge, SUM(LsPo.Menge * Artikel.StueckGewicht) AS LsGewicht, RechPo.EPreis
INTO CPSalesDemo.dbo.Rechnungsdaten
FROM LsPo, LsKo, RechPo, RechKo, KdArti, Artikel, KdGf, Holding, ABC, ArtGru, Konten, Standort, KdBer, Mitarbei, Kunden
LEFT OUTER JOIN KdGru ON KdGru.KundenID = Kunden.ID
JOIN AdrGrp ON AdrGrp.ID = KdGru.AdrGrpID
WHERE LsPo.LsKoID = LsKo.ID
  AND LsPo.RechPoID = RechPo.ID
  AND RechPo.RechKoID = RechKo.ID
  AND Rechko.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Kunden.HoldingID = Holding.ID
  AND Kunden.AbcID = ABC.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND RechPo.KontenID = Konten.ID
  AND LsPo.ProduktionID = Standort.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BetreuerID = Mitarbei.ID
  --AND RechKo.RechDat >= N'2017-01-01'
  AND Kunden.Debitor IS NOT NULL
GROUP BY Kunden.Debitor, RTRIM(Kunden.Name1) + IIF(Kunden.Name2 IS NOT NULL, ' ' + RTRIM(Kunden.Name2), ''), KdGf.KurzBez, Holding.Bez, IIF(ISNUMERIC(AdrGrp.Nr) = 0, AdrGrp.Nr, KdGf.KurzBez), ABC.Abc, Mitarbei.Initialen, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGru.ArtGruBez, Konten.Konto, RechPo.KsSt, Standort.Bez, YEAR(LsKo.Datum), MONTH(LsKo.Datum), RechPo.EPreis;

-- Table Skonto

DROP TABLE IF EXISTS CPSalesDemo.dbo.Skonto;

SELECT Kunden.Debitor AS Kostentraeger, ZahlZiel.Skonto
INTO CPSalesDemo.dbo.Skonto
FROM Kunden, ZahlZiel
WHERE Kunden.ZahlZielID = ZahlZiel.ID
  AND Kunden.Debitor IS NOT NULL;

-- Table Bonus
-- importiert aus Excel-Datei