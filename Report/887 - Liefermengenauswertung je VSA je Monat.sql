WITH LiefermengeMonatlich AS (
  SELECT DATEPART(year, LsKo.Datum) AS Jahr, DATEPART(month, LsKo.Datum) AS Monat, LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, LsPo.ArtGroeID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT') BETWEEN FORMAT(DATEADD(year, -1, GETDATE()), N'yyyy-MM', N'de-AT') AND FORMAT(GETDATE(), N'yyyy-MM', N'de-AT')
    AND LsKo.Status >= N'Q'
  GROUP BY DATEPART(year, LsKo.Datum), DATEPART(month, LsKo.Datum), LsKo.VsaID, LsPo.KdArtiID, LsPo.AbteilID, LsPo.ArtGroeID
)
SELECT ProdBetrieb.SuchCode AS [produzierender Betrieb], IntProdBetrieb.SuchCode AS [intern produzierender Betrieb], Holding.Holding AS Kette, Kunden.KdNr AS Kundennummer, Kunden.SuchCode AS Kundenname, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Bereich.Bereich AS Produktbereich, ArtGru.Gruppe AS Artikelgruppe, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Artikel.StueckGewicht AS Gewicht, LiefArt.LiefArt AS Auslieferart, LiefermengeMonatlich.Jahr, LiefermengeMonatlich.Monat, LiefermengeMonatlich.Liefermenge
FROM LiefermengeMonatlich
JOIN Vsa ON LiefermengeMonatlich.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON LiefermengeMonatlich.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
JOIN ArtGroe ON LiefermengeMonatlich.ArtGroeID = ArtGroe.ID
JOIN Abteil ON LiefermengeMonatlich.AbteilID = Abteil.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Bereich.ID
JOIN Standort AS ProdBetrieb ON StandBer.ExpeditionID = ProdBetrieb.ID
JOIN Standort AS IntProdBetrieb ON StandBer.ProduktionID = IntProdBetrieb.ID
WHERE Kunden.KdNr = 261012
ORDER BY Kundennummer, [VSA-Nummer], Jahr, Monat, Artikelnummer;