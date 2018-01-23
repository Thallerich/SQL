SELECT Standort.Bez AS Lagerstandort, Firma.Bez AS Firma, KdGF.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, y.SuchCode AS VsaStichwort, y.VsaBez AS VsaBezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, AnzGebr, AnzNeu, WertNeu, AnzNeuNeukunde, WertNeuNeukunde, Mitarbei.Nachname AS Betreuer
FROM KdGF, Kunden, Artikel, KdBer, Mitarbei, Firma, LagerArt, Standort, (
  SELECT Vsa.KundenID, ArtGroe.ArtikelID, Vsa.SuchCode, Vsa.Bez AS VsaBez, x.LagerArtID,
    SUM(IIF(Neukunde = 1, IIF(Neu = 1, Anzahl, 0), 0)) AnzNeuNeukunde,
    SUM(IIF(Neukunde = 0, IIF(Neu = 1, Anzahl, 0), 0)) AnzNeu,
    SUM(IIF(Neu = 0, Anzahl, 0)) AnzGebr,
    SUM(CONVERT(money, IIF(Neukunde = 0, IIF(Neu = 1, Anzahl * ArtGroe.EkPreis, 0), 0))) WertNeu,
    SUM(CONVERT(money, IIF(Neukunde = 1, IIF(Neu = 1, Anzahl * ArtGroe.EkPreis, 0), 0))) WertNeuNeukunde
  FROM Vsa, ArtGroe, (
    SELECT Teile.VsaID, Teile.ArtGroeID, Teile.LagerArtID,
      IIF(Teile.LagerartID IN (SELECT ID FROM LagerArt WHERE Neuwertig = $TRUE$), 1, 0) AS Neu,
      IIF(Teile.EinsatzGrund IN ('1', '2'), 1, 0) AS Neukunde,
      COUNT(*) Anzahl
    FROM Teile
    WHERE Teile.Patchdatum BETWEEN $1$ AND $2$
      AND Teile.LagerArtID > 0
      AND Teile.KaufwareModus <> 1
      AND Teile.KaufwareModus <> 2
    GROUP BY Teile.VsaID, Teile.ArtGroeID, Teile.LagerArtID, Teile.EinsatzGrund
  ) AS x
  WHERE x.ArtGroeID = ArtGroe.ID
    AND x.VsaID = Vsa.ID
  GROUP BY Vsa.KundenID, ArtGroe.ArtikelID, Vsa.SuchCode, Vsa.Bez, x.LagerArtID
) AS y
WHERE y.KundenID = Kunden.ID
  AND y.ArtikelID = Artikel.ID
  AND KdGf.ID = Kunden.KdGfID
  AND Artikel.BereichID = 100
  AND KdBer.BetreuerID = Mitarbei.ID
  AND KdBer.KundenID = Kunden.ID
  AND KdBer.BereichID = 100
  AND Kunden.FirmaID = Firma.ID
  AND y.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
ORDER BY Firma, SGF, Kunden.KdNr;