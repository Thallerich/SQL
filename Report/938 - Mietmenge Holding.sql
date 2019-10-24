SELECT Expedition.Bez AS [Produzierender Betrieb], Produktion.Bez AS [Intern produzierender Betrieb], Holding.Holding AS Kette, Kunden.KdNr AS Kundennummer, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, CAST(LEFT(Abteil.RechnungsMemo, 200) AS nvarchar(200)) AS [Externe Bestellnummer], Bereich.Bereich AS Aktivität, ArtGru.Gruppe AS Produktgruppe, Artikel.ArtikelNr AS Produkt, Artikel.ArtikelBez AS Produktbeschreibung, SUM(AbtKdArW.Menge) AS Mietmenge, Wochen.Woche AS Kalenderwoche
FROM AbtKdArW
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN Abteil ON AbtKdArW.AbteilID = Abteil.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON AbtKdArW.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Bereich.ID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Expedition ON StandBer.ExpeditionID = Expedition.ID
WHERE Holding.ID IN ($2$)
  AND Wochen.Woche = $1$
GROUP BY Expedition.Bez, Produktion.Bez, Holding.Holding, KUnden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Abteil.Abteilung, Abteil.Bez, Abteil.RechnungsMemo, Bereich.Bereich, ArtGru.Gruppe, Artikel.ArtikelNr, Artikel.ArtikelBez, Wochen.Woche;