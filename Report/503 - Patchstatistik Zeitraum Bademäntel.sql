SELECT Firma.Bez AS Firma, KdGF.KdGfBez$LAN$ AS SGF, Kunden.KdNr, Kunden.Name1, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, y.AnzNeu, y.WertNeu, y.AnzNeuNeukunde, y.WertNeuNeukunde, Mitarbei.Nachname AS Betreuer
FROM KdGF, Kunden, Artikel, KdBer, Mitarbei, Firma, (
  SELECT Vsa.KundenID, ArtGroe.ArtikelID, SUM(IIF(x.Neukunde = 1, IIF(x.Neu = 1, x.Anzahl, 0), 0)) AS AnzNeuNeukunde, SUM(IIF(x.Neukunde = 0, IIF(x.Neu = 1, x.Anzahl, 0), 0)) AS AnzNeu, SUM(IIF(x.Neu = 0, x.Anzahl, 0)) AS AnzGebr, SUM(CONVERT(money, IIF(x.Neukunde = 0, IIF(x.Neu = 1, x.Anzahl*ArtGroe.EkPreis, 0), 0))) AS WertNeu, SUM(CONVERT(money, IIF(x.Neukunde = 1, IIF(x.Neu = 1, x.Anzahl*ArtGroe.EkPreis, 0), 0))) AS WertNeuNeukunde
  FROM Vsa, ArtGroe, (
    SELECT Teile.VsaID, Teile.ArtGroeID, IIF(Teile.LagerartID IN (1, 1006), 1, 0) AS Neu, IIF(Teile.EinsatzGrund IN ('1', '2'), 1, 0) AS Neukunde, COUNT(*) AS Anzahl
    FROM Teile
    WHERE Teile.Patchdatum BETWEEN $1$ AND $2$ 
      AND Teile.LagerArtID <> -1
    GROUP BY Teile.VsaID, Teile.ArtGroeID, IIF(Teile.LagerartID IN (1, 1006), 1, 0), IIF(Teile.EinsatzGrund IN ('1', '2'), 1, 0)
  ) AS x
  WHERE x.ArtGroeID = ArtGroe.ID
    AND x.VsaID = Vsa.ID
  GROUP BY Vsa.KundenID, ArtGroe.ArtikelID
) AS y
WHERE y.KundenID = Kunden.ID 
  AND Kunden.FirmaID = Firma.ID
  AND y.ArtikelID = Artikel.ID
  AND KdGF.ID = Kunden.KdGfID
  AND Artikel.BereichID = 102
  AND KdBer.BetreuerID = Mitarbei.ID
  AND KdBer.KundenID = Kunden.ID 
  AND KdBer.BereichID = Artikel.BereichID
ORDER BY Firma, SGF, Kunden.Name1;