SELECT Firma.Bez, KdGF.KurzBez$LAN$ AS SGF, Kunden.KdNr, Kunden.Name1 AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, y.AnzGebr, y.AnzNeu, y.WertNeu, y.AnzNeuNeukunde, y.WertNeuNeukunde, Mitarbei.Nachname AS Betreuer, y.Barcode, y.EinsatzGrund
FROM KdGF, Kunden, Artikel, KdBer, Mitarbei, Firma, (
  SELECT KundenID, ArtikelID, x.Barcode, x.EinsatzGrund,
    IIF(Neukunde = 1, IIf(Neu = 1, Anzahl, 0), 0) AnzNeuNeukunde,
    IIF(Neukunde = 0, IIf(Neu = 1, Anzahl, 0), 0) AnzNeu,
    IIf(Neu = 0, Anzahl, 0) AnzGebr,
    CONVERT(money, IIF(Neukunde = 0, IIF(Neu = 1, Anzahl * ArtGroe.EkPreis, 0), 0)) WertNeu,
    CONVERT(money, IIF(Neukunde = 1, IIF(Neu = 1, Anzahl * ArtGroe.EkPreis, 0), 0)) WertNeuNeukunde
  FROM Vsa, ArtGroe, (
    SELECT EinzHist.VsaID, EinzHist.ArtGroeID, EinzHist.Barcode, EinzHist.EinsatzGrund,
      IIF(EinzHist.LagerartID IN (1, 1006), 1, 0) as Neu,
      IIF(EinzHist.EinsatzGrund IN ('1', '2'), 1, 0) as Neukunde,
      1 AS Anzahl
    FROM EinzHist
    WHERE EinzHist.IsCurrEinzHist = 1
      AND EinzHist.EinzHistTyp = 1
      AND EinzHist.PoolFkt = 0
      AND EinzHist.Patchdatum BETWEEN $STARTDATE$ AND $ENDDATE$
      AND EinzHist.LagerArtID > 0
      AND EinzHist.KaufwareModus NOT IN (1, 2)
  ) as x
  WHERE x.ArtGroeID = ArtGroe.ID
    AND x.VsaID = Vsa.ID
) as y
WHERE y.KundenID = Kunden.ID
  AND Kunden.FirmaID=Firma.ID
  AND y.ArtikelID = Artikel.ID
  AND KdGF.ID = Kunden.KdGfID
  AND Artikel.BereichID = 100
  AND KdBer.BetreuerID = Mitarbei.ID
  AND KdBer.KundenID = Kunden.ID
  AND KdBer.BereichID = 100
ORDER BY Firma.Bez, SGF, Kunde;