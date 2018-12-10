SELECT Firma.Bez AS Firma, KdGF.KdGfBez$LAN$ AS SGF, Kunden.KdNr, Kunden.Name1, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, y.AnzGebrKaufw, y.AnzNeuKaufw, y.WertNeuKaufw, Mitarbei.Nachname AS Betreuer
FROM KdGf, Kunden, Artikel, KdBer, Mitarbei, Firma, (
  SELECT Vsa.KundenID, ArtGroe.ArtikelID, SUM(IIF(Neukunde=1, IIf(Neu=1, Anzahl, 0),0)) AS AnzNeuKaufw, SUM(IIF(Neukunde=0, IIf(Neu=1, Anzahl, 0),0)) AS AnzNeu, SUM(IIf(Neu=0, Anzahl, 0)) AS AnzGebrKaufw, SUM(CONVERT(money, IIF(Neukunde=0, IIF(Neu=1, Anzahl*ArtGroe.EkPreis, 0), 0))) AS WertNeu, SUM(CONVERT(money, IIF(Neukunde=1, IIF(Neu=1, Anzahl*ArtGroe.EkPreis, 0), 0))) AS WertNeuKaufw
  FROM Vsa, ArtGroe, (
    SELECT Teile.VsaID, Teile.ArtGroeID, IIF(Teile.LagerartID IN (1, 1006), 1, 0) AS Neu, IIF(KaufwareModus IN (1, 2), 1, 0) AS Neukunde, COUNT(*) Anzahl
    FROM Teile
    WHERE Teile.Patchdatum BETWEEN $1$ and $2$ 
    AND Teile.LagerArtID > 0
    AND Teile.KaufwareModus <> 0
    GROUP BY Teile.VsaID, Teile.ArtGroeID, IIF(Teile.LagerartID IN (1, 1006), 1, 0), IIF(KaufwareModus IN (1, 2), 1, 0)
  ) AS x
  WHERE x.ArtGroeID = ArtGroe.ID
    AND x.VsaID = Vsa.ID
  GROUP BY Vsa.KundenID, ArtGroe.ArtikelID
) AS y
WHERE y.KundenID = Kunden.ID 
  AND Kunden.FirmaID = Firma.ID
  AND y.ArtikelID = Artikel.ID
  AND KdGf.ID = Kunden.KdGfID 
  AND Artikel.BereichID = 100
  AND KdBer.BetreuerID = Mitarbei.ID 
  AND KdBer.KundenID = Kunden.ID
  AND KdBer.BereichID = Artikel.BereichID
ORDER BY Firma, SGF, Kunden.Name1;