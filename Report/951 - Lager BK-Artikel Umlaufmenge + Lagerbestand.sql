DECLARE @currentweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);

DROP TABLE IF EXISTS #TmpResult951;

SELECT Artikel.ArtikelNr, Status.Bez AS Artikelstatus, ArtGru.Gruppe, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ProdGru.ProdGruBez$LAN$ AS Sortiment, ArtGroe.Groesse, GroePo.Folge, 0 AS Umlaufmenge, 0 AS [Bestand Neuware], 0 AS [Bestand Gebraucht], 0 AS [Entnahme Neuware], 0 AS [Entnahme Gebraucht], ArtGroe.ID AS ArtGroeID
INTO #TmpResult951
FROM ArtGroe, Artikel, Bereich, ProdGru, GroePo, GroeKo, ARTGRU, (SELECT Status.Status, Status.StatusBez$LAN$ AS Bez FROM Status WHERE Status.Tabelle = 'ARTIKEL') AS Status
WHERE ArtGroe.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Artikel.Status = Status.Status
  AND Artikel.ProdGruID = ProdGru.ID
  AND ArtGroe.Groesse = GroePo.Groesse
  AND GroePo.GroeKoID = GroeKo.ID
  AND Artikel.GroeKoID = GroeKo.ID
  AND ArtGroe.ArtikelID > 0
  AND Artikel.ArtGruID = Artgru.ID
  AND ArtGru.ID IN ($3$);

WITH UmlaufCalc AS (
  SELECT VsaLeas.VsaID, Vsa.StandKonID, KdBer.BereichID, - 1 AS TraegerID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaLeas.Menge) AS Umlauf
  FROM VsaLeas
  JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
  JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
  WHERE @currentweek BETWEEN ISNULL(VsaLeas.Indienst, N'1980/01') AND ISNULL(VsaLeas.Ausdienst, N'2099/52')
  GROUP BY VsaLeas.VsaID, Vsa.StandKonID, KdBer.BereichID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID

  UNION ALL

  SELECT VsaAnf.VsaID, Vsa.StandKonID, KdBer.BereichID, - 1 AS TraegerID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaAnf.Bestand) AS Umlauf
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
  WHERE VsaAnf.Bestand != 0
    AND VsaAnf.[Status] = N'A'
  GROUP BY VsaAnf.VsaID, Vsa.StandKonID, KdBer.BereichID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1), KdArti.ArtikelID

  UNION ALL

  SELECT Strumpf.VsaID, Vsa.StandKonID, KdBer.BereichID, - 1 AS TraegerID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(Strumpf.ID) AS Umlauf
  FROM Strumpf
  JOIN Vsa ON Strumpf.VsaID = Vsa.ID
  JOIN KdArti ON Strumpf.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
  WHERE Strumpf.[Status] != N'X'
    AND ISNULL(Strumpf.Indienst, N'1980/01') >= @currentweek
    AND Strumpf.WegGrundID < 0
  GROUP BY Strumpf.VsaID, Vsa.StandKonID, KdBer.BereichID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID
  
  UNION ALL

  SELECT Traeger.VsaID, Vsa.StandKonID, KdBer.BereichID, TraeArti.TraegerID, TraeArti.KdArtiID, TraeArti.ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  WHERE @currentweek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')

  UNION ALL

  SELECT Traeger.VsaID, Vsa.StandKonID, KdBer.BereichID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
  JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
  WHERE @currentweek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
    AND KdArAppl.ArtiTypeID = 3  --Emblem

  UNION ALL

  SELECT Traeger.VsaID, Vsa.StandKonID, KdBer.BereichID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
  JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
  WHERE @currentweek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
    AND KdArAppl.ArtiTypeID = 2 --Namenschild
)
UPDATE R SET Umlaufmenge = x.Umlaufmenge
FROM #TmpResult951 AS R, (
  SELECT UmlaufCalc.ArtGroeID, SUM(UmlaufCalc.Umlauf) AS Umlaufmenge
  FROM UmlaufCalc
  JOIN StandBer ON UmlaufCalc.StandKonID = StandBer.StandKonID AND UmlaufCalc.BereichID = StandBer.BereichID
  WHERE (StandBer.LagerID IN ($1$) OR StandBer.LokalLagerID IN ($1$))
  GROUP BY UmlaufCalc.ArtGroeID
) AS x
WHERE x.ArtGroeID = R.ArtGroeID;

UPDATE R SET [Bestand Neuware] = x.Bestand
FROM #TmpResult951 AS R, (
  SELECT Bestand.ArtGroeID, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand, LagerArt
  WHERE Bestand.LagerArtID = LagerArt.ID
    AND LagerArt.LagerID IN ($1$)
    AND LagerArt.Neuwertig = 1
  GROUP BY Bestand.ArtGroeID
) AS x
WHERE x.ArtGroeID = R.ArtGroeID;

UPDATE R SET [Bestand Gebraucht] = x.Bestand
FROM #TmpResult951 AS R, (
  SELECT Bestand.ArtGroeID, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand, LagerArt
  WHERE Bestand.LagerArtID = LagerArt.ID
    AND LagerArt.LagerID IN ($1$)
    AND LagerArt.Neuwertig = 0
  GROUP BY Bestand.ArtGroeID
) AS x
WHERE x.ArtGroeID = R.ArtGroeID;

UPDATE R SET [Entnahme Neuware] = x.EntnahmeMenge
FROM #TmpResult951 AS R, (
  SELECT Bestand.ArtGroeID, SUM(Bestand.Entnahme01 + Bestand.Entnahme02 + Bestand.Entnahme03 + Bestand.Entnahme04 + Bestand.Entnahme05 + Bestand.Entnahme06 + Bestand.Entnahme07 + Bestand.Entnahme08 + Bestand.Entnahme09 + Bestand.Entnahme10 + Bestand.Entnahme11 + Bestand.Entnahme12) AS EntnahmeMenge
  FROM Bestand, Lagerart
  WHERE Bestand.LagerArtID = Lagerart.ID
    AND Lagerart.LagerID IN ($1$)
    AND Lagerart.Neuwertig = 1
  GROUP BY Bestand.ArtGroeID
) AS x
WHERE x.ArtGroeID = R.ArtGroeID;

UPDATE R SET [Entnahme Gebraucht] = x.EntnahmeMenge
FROM #TmpResult951 AS R, (
  SELECT Bestand.ArtGroeID, SUM(Bestand.Entnahme01 + Bestand.Entnahme02 + Bestand.Entnahme03 + Bestand.Entnahme04 + Bestand.Entnahme05 + Bestand.Entnahme06 + Bestand.Entnahme07 + Bestand.Entnahme08 + Bestand.Entnahme09 + Bestand.Entnahme10 + Bestand.Entnahme11 + Bestand.Entnahme12) AS EntnahmeMenge
  FROM Bestand, Lagerart
  WHERE Bestand.LagerArtID = Lagerart.ID
    AND Lagerart.LagerID IN ($1$)
    AND Lagerart.Neuwertig = 0
  GROUP BY Bestand.ArtGroeID
) AS x
WHERE x.ArtGroeID = R.ArtGroeID;

SELECT Gruppe, ArtikelNr, Artikelstatus, Artikelbezeichnung, Sortiment, Groesse, Umlaufmenge, [Bestand Neuware], [Bestand Gebraucht], [Entnahme Neuware], [Entnahme Gebraucht]
FROM #TmpResult951
WHERE (($2$ = 0) OR ($2$ = 1 AND ([Bestand Neuware] != 0 OR [Bestand Gebraucht] != 0 OR Umlaufmenge != 0)))
ORDER BY ArtikelNr, Folge;