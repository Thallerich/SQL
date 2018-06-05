IF object_id('tempdb..#TmpTblAnzLs400a') IS NOT NULL
  DROP TABLE #TmpTblAnzLs400a;

SELECT $1$ AS [Datum von], $2$ AS [Datum bis], Abteil.Abteilung AS KsSt, Abteil.Bez AS Kostenstelle, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, COUNT(DISTINCT LsKo.ID) AS [Anzahl Lieferungen], 0 AS [Berechnete Lieferungen], 0 AS [Kostenlose Lieferungen], SUM(LsPo.Menge) AS [Liefermenge], 0 AS [Teile beim Kunden], Abteil.ID AS AbteilID, LsPo.KdArtiID, Artikel.ID AS ArtikelID, AnfKo.VsaID
INTO #TmpTblAnzLs400a
FROM AnfKo, LsKo, LsPo, KdArti, Artikel, Abteil
WHERE AnfKo.LsKoID = LsKo.ID
  AND LsPo.LsKoID = LsKo.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND LsPo.AbteilID = Abteil.ID
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND AnfKo.Sonderfahrt = 1
GROUP BY Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, Abteil.ID, LsPo.KdArtiID, Artikel.ID, AnfKo.VsaID;

UPDATE AnzLs SET AnzLs.[Kostenlose Lieferungen] = a.Kostenlos
FROM #TmpTblAnzLs400a AnzLs, (
  SELECT LsPo.AbteilID, LsPo.KdArtiID, COUNT(DISTINCT LsKo.ID) AS Kostenlos
  FROM AnfKo, LsKo, LsPo
  WHERE AnfKo.LsKoID = LsKo.ID
    AND LsPo.LsKoID = LsKo.ID
    AND LsKo.Datum BETWEEN $1$ AND $2$
    AND AnfKo.Sonderfahrt = 1
    AND NOT EXISTS (
      SELECT Pos.*
      FROM LsPo AS Pos
      JOIN KdArti ON Pos.KdArtiID = KdArti.ID
      JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
      WHERE Pos.LsKoID = LsKo.ID
        AND Artikel.ArtikelNr = N'A00001'
    )
    AND ISNULL(AnfKo.LiefBerechArt, N'') <> N'A'
  GROUP BY LsPo.AbteilID, LsPo.KdArtiID
) a
WHERE AnzLs.AbteilID = a.AbteilID
  AND AnzLs.KdArtiID = a.KdArtiID;
  
UPDATE AnzLs SET AnzLs.[Berechnete Lieferungen] = a.Berechnet
FROM #TmpTblAnzLs400a AnzLs, (
  SELECT LsPo.AbteilID, LsPo.KdArtiID, COUNT(DISTINCT LsKo.ID) AS Berechnet
  FROM AnfKo, LsKo, LsPo
  WHERE AnfKo.LsKoID = LsKo.ID
    AND LsPo.LsKoID = LsKo.ID
    AND LsKo.Datum BETWEEN $1$ AND $2$
    AND AnfKo.Sonderfahrt = 1
     AND (
      EXISTS (
        SELECT Pos.*
        FROM LsPo AS Pos
        JOIN KdArti ON Pos.KdArtiID = KdArti.ID
        JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
        WHERE Pos.LsKoID = LsKo.ID
          AND Artikel.ArtikelNr = N'A00001'
      )
      OR AnfKo.LiefBerechArt = N'A'
    )
  GROUP BY LsPo.AbteilID, LsPo.KdArtiID
) a
WHERE AnzLs.AbteilID = a.AbteilID
  AND AnzLs.KdArtiID = a.KdArtiID;

UPDATE AnzLs SET AnzLs.[Teile beim Kunden] = x.Anz
FROM #TmpTblAnzLs400a AnzLs, (
  SELECT OPTeile.ArtikelID, OPTeile.VsaID, COUNT(OPTeile.ID) AS Anz
  FROM OPTeile
  WHERE OPTeile.Status IN (N'A', N'Q')
    AND OPTeile.LastActionsID = 102
    AND OPTeile.VsaID IN (SELECT VsaID FROM #TmpTblAnzLs400a)
  GROUP BY OPTeile.ArtikelID, OPTeile.VsaID
) x
WHERE x.VsaID = AnzLs.VsaID
  AND x.ArtikelID = AnzLs.ArtikelID;
  
SELECT [Datum von], [Datum bis], KsSt, Kostenstelle, ArtikelNr, Artikelbezeichnung, [Anzahl Lieferungen], [Berechnete Lieferungen], [Kostenlose Lieferungen], Liefermenge, [Teile beim Kunden] 
FROM #TmpTblAnzLs400a;