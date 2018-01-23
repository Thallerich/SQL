DECLARE @1 NVARCHAR(12);
DECLARE @von TIMESTAMP;
DECLARE @bis TIMESTAMP;

@1 = '04.07.2016';
@von = CONVERT(@1 + ' 00:00:00', SQL_TIMESTAMP);
@bis = CONVERT(@1 + ' 23:59:59', SQL_TIMESTAMP);

TRY
  DROP TABLE #TmpChipRead;
CATCH ALL END;

SELECT OPTeile.Code, TRUE AS ReadLift, FALSE AS ReadTor, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, OPScans.Zeitpunkt AS TimeLift, CONVERT(NULL, SQL_TIMESTAMP) AS TimeTor, OPTeile.ID AS OPTeileID, 0 AS VsaID
INTO #TmpChipRead
FROM OPScans, OPTeile, Artikel
WHERE OPScans.OPTeileID = OPTeile.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND OPScans.Zeitpunkt BETWEEN @von AND @bis
  AND OPScans.ZielNrID IN (282, 283, 284, 285);

UPDATE CR SET CR.ReadTor = TRUE, CR.TimeTor = x.TimeTor
FROM #TmpChipRead AS CR, (
  SELECT OPScans.OPTeileID, OPScans.Zeitpunkt AS TimeTor
  FROM OPScans, #TmpChipRead AS ChipRead
  WHERE OPScans.OPTeileID = ChipRead.OPTeileID
    AND OPScans.Zeitpunkt < ChipRead.TimeLift
    AND OPScans.ZielNrID = 291
    AND OPScans.Zeitpunkt > (SELECT MAX(O.Zeitpunkt) FROM OPScans O WHERE O.OPTeileID = OPScans.OPTeileID AND O.AnfPoID > 0 AND O.Zeitpunkt < ChipRead.TimeLift)
) AS x
WHERE x.OPTeileID = CR.OPTeileID;

UPDATE ChipRead SET ChipRead.VsaID = y.VsaID
FROM #TmpChipRead AS ChipRead, (
  SELECT OPScans.OPTeileID, AnfKo.VsaID
  FROM OPScans, AnfPo, AnfKo, (
    SELECT CR.OPTeileID, MAX(OPScans.ID) AS OPScansID
    FROM OPScans, #TmpChipRead AS CR
    WHERE OPScans.OPTeileID = CR.OPTeileID
      AND OPScans.AnfPoID > 0
      AND OPScans.Zeitpunkt < CR.TimeLift
	GROUP BY CR.OPTeileID
  ) AS x
  WHERE OPScans.AnfPoID = AnfPo.ID
    AND AnfPo.AnfKoID = AnfKo.ID
    AND OPScans.ID = x.OPScansID
) AS y
WHERE y.OPTeileID = ChipRead.OPTeileID;

SELECT ChipRead.Code, ChipRead.ReadLift, ChipRead.ReadTor, ChipRead.ArtikelNr, ChipRead.Artikelbezeichnung, ChipRead.TimeTor, ChipRead.TimeLift, TIMESTAMPDIFF(SQL_TSI_DAY, ChipRead.TimeTor, ChipRead.TimeLift) AS TageTorLift, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, ChipRead.VsaID
FROM #TmpChipRead AS ChipRead, Vsa, Kunden
WHERE ChipRead.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID;