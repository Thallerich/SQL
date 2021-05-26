WITH PatchTeile AS (
  SELECT Teile.VsaID, Teile.ArtGroeID, LagerArt.ID AS LagerArtID, LagerArt.LagerID,
    IIF(LagerArt.Neuwertig = 1 OR Week.Woche = Teile.Indienst, 1, 0) AS Neu,
    IIF(Teile.EinsatzGrund IN ('1', '2'), 1, 0) AS Neukunde,
    COUNT(*) Anzahl
  FROM Teile
  JOIN Week ON DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
  JOIN LagerArt ON Teile.LagerArtID = LagerArt.ID
  WHERE Teile.Patchdatum BETWEEN $1$ AND $2$
    AND Teile.LagerArtID > 0
    AND Teile.KaufwareModus <> 1
    AND Teile.KaufwareModus <> 2
  GROUP BY Teile.VsaID, Teile.ArtGroeID, LagerArt.ID, LagerArt.LagerID, IIF(LagerArt.Neuwertig = 1 OR Week.Woche = Teile.Indienst, 1, 0), IIF(Teile.EinsatzGrund IN ('1', '2'), 1, 0)
)
SELECT y.Lagerstandort, Firma.Bez AS Firma, KdGF.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, y.SuchCode AS VsaStichwort, y.VsaBez AS VsaBezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, y.AnzGebr, y.AnzNeu, y.WertNeu, y.AnzNeuNeukunde, y.WertNeuNeukunde, Mitarbei.Nachname AS Betreuer, Produktion.Bez AS Produktionsstandort, Lief.LiefNr AS Lieferantennummer, Lief.SuchCode AS Lieferant
FROM KdGF, Kunden, Artikel, KdBer, Mitarbei, Firma, StandBer, Standort AS Produktion, Lief, (
  SELECT Vsa.StandKonID, Vsa.KundenID, ArtGroe.ArtikelID, Vsa.SuchCode, Vsa.Bez AS VsaBez, Standort.Bez AS Lagerstandort,
    SUM(IIF(Neukunde = 1 AND Neu = 1, Anzahl, 0)) AnzNeuNeukunde,
    SUM(IIF(Neukunde = 0 AND Neu = 1, Anzahl, 0)) AnzNeu,
    SUM(IIF(Neu = 0, Anzahl, 0)) AnzGebr,
    SUM(CONVERT(money, IIF(Neukunde = 0 AND Neu = 1, Anzahl * ArtGroe.EkPreis, 0))) WertNeu,
    SUM(CONVERT(money, IIF(Neukunde = 1 AND Neu = 1, Anzahl * ArtGroe.EkPreis, 0))) WertNeuNeukunde
  FROM Vsa, ArtGroe, PatchTeile, Standort
  WHERE PatchTeile.ArtGroeID = ArtGroe.ID
    AND PatchTeile.VsaID = Vsa.ID
    AND PatchTeile.LagerID = Standort.ID
  GROUP BY Vsa.StandKonID, Vsa.KundenID, ArtGroe.ArtikelID, Vsa.SuchCode, Vsa.Bez, Standort.Bez
) AS y
WHERE y.KundenID = Kunden.ID
  AND y.ArtikelID = Artikel.ID
  AND KdGf.ID = Kunden.KdGfID
  AND Artikel.BereichID = 100
  AND KdBer.BetreuerID = Mitarbei.ID
  AND KdBer.KundenID = Kunden.ID
  AND KdBer.BereichID = 100
  AND Kunden.FirmaID = Firma.ID
  AND y.StandKonID = StandBer.StandKonID
  AND StandBer.BereichID = 100
  AND StandBer.ProduktionID = Produktion.ID
  AND Artikel.LiefID = Lief.ID
ORDER BY Firma, SGF, Kunden.KdNr;