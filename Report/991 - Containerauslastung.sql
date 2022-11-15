IF object_id('tempdb..#TmpContainer') IS NOT NULL
BEGIN
  DROP TABLE #TmpContainer;
END

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, LsKo.LsNr, 0 AS AnzContainGesamt, 30 AS Sollgewicht, 0 AS LiefertageWoche, 0 AS Schnittgewicht, LsKo.ID AS LsKoID, Vsa.ID AS VsaID
INTO #TmpContainer
FROM LsKo, Vsa, Kunden
WHERE LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsKo.Datum = $3$
  AND Vsa.StandKonID IN ($1$)
  AND LsKo.Status >= 'M';

IF object_id('tempdb..#TmpInhalt') IS NOT NULL
BEGIN
  DROP TABLE #TmpInhalt;
END

SELECT Contain.Barcode, x.LsKoID, SUM(Artikel.StueckGewicht) AS Gewicht
INTO #TmpInhalt
FROM (
  SELECT Scans.AnfPoID, Scans.ContainID, Scans.EinzTeilID
  FROM Scans
  WHERE Scans.AnfPoID IN (
    SELECT AnfPo.ID
    FROM AnfPo, AnfKo
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND AnfKo.LsKoID IN (SELECT LsKoID FROM #TmpContainer)
  )
) AS OPScans, AnfPo, AnfKo, EinzTeil, Artikel, Contain, #TmpContainer AS x
WHERE OPScans.AnfPoID = AnfPo.ID
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.LsKoID = x.LsKoID
  AND OPScans.EinzTeilID = EinzTeil.ID
  AND EinzTeil.ArtikelID = Artikel.ID
  AND OPScans.ContainID = Contain.ID
GROUP BY Contain.Barcode, x.LsKoID;

UPDATE Container SET Container.LiefertageWoche = y.Liefertage
FROM #TmpContainer AS Container, (
  SELECT COUNT(DISTINCT Touren.Wochentag) AS Liefertage, x.VsaID
  FROM VsaTour, Touren, #TmpContainer AS x
  WHERE VsaTour.TourenID = Touren.ID
    AND VsaTour.VsaID = x.VsaID
  GROUP BY x.VsaID
) AS y
WHERE y.VsaID = Container.VsaID;

UPDATE Container SET Container.AnzContainGesamt = x.AnzContainer
FROM #TmpContainer AS Container, (
  SELECT Inhalt.LsKoID, COUNT(DISTINCT Barcode) AS AnzContainer
  FROM #TmpInhalt AS Inhalt
  GROUP BY Inhalt.LsKoID
) AS x
WHERE x.LsKoID = Container.LsKoID;

SELECT Container.KdNr, Container.Kunde, Container.VsaStichwort, Container.Vsa, Container.LsNr, Container.AnzContainGesamt AS [Gesamtanzahl Container], Inhalt.Barcode AS Containerbarcode, Container.Sollgewicht AS [Soll-Gewicht], ROUND(Inhalt.Gewicht, 2) AS [Ist-Gewicht], Container.LiefertageWoche AS [Anzahl Liefertage je Woche] --, Container.Schnittgewicht AS [Durchschnittsgewicht je Lieferung]
FROM #TmpContainer AS Container, #TmpInhalt AS Inhalt
WHERE Container.LsKoID = Inhalt.LsKoID
  AND (($2$ = 0) OR ($2$ = 1 AND Container.Sollgewicht > Inhalt.Gewicht))
ORDER BY Container.KdNr, Container.VsaStichwort, Container.Vsa, Container.LsNr;