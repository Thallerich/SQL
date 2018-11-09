-- Anzahl Kunden
SELECT COUNT(DISTINCT KundenID) AS [Anzahl Kunden]
FROM (
  SELECT DISTINCT Kunden.ID AS KundenID
  FROM OPTeile
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Kunden.Status = N'A'
    AND Vsa.Status = N'A'

  UNION ALL

  SELECT DISTINCT Kunden.ID AS KundenID
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Kunden.Status = N'A'
    AND Vsa.Status = N'A'
    AND Teile.Status = N'Q'
    AND (LEN(Teile.Barcode) = 16 OR LEN(Teile.RentomatChip) = 16 OR LEN(Teile.Barcode) = 24 OR LEN(Teile.RentomatChip) = 24 OR (LEN(Teile.Barcode) = 12 AND Teile.Barcode LIKE N'D00%') OR (LEN(Teile.RentomatChip) = 12 AND Teile.RentomatChip LIKE N'D00%'))
) AS x;

-- Anzahl Teile
SELECT N'UHF-Pool' AS Art, COUNT(OPTeile.ID) AS ChipTeile
FROM OPTeile
WHERE LEN(OPTeile.Code) = 24
  AND OPTeile.Status = N'Q'

UNION ALL

SELECT N'BK-Teile' AS Art, COUNT(Teile.ID) AS ChipTeile
FROM Teile
WHERE (LEN(Teile.Barcode) = 16 OR LEN(Teile.RentomatChip) = 16 OR LEN(Teile.Barcode) = 24 OR LEN(Teile.RentomatChip) = 24 OR (LEN(Teile.Barcode) = 12 AND Teile.Barcode LIKE N'D00%') OR (LEN(Teile.RentomatChip) = 12 AND Teile.RentomatChip LIKE N'D00%'))
  AND Teile.Status = N'Q';

-- Anzahl Chips je Technologie
SELECT x.Tech, SUM(x.ChipAnz) AS Chips
FROM (
  SELECT N'UHF' AS Tech, COUNT(OPTeile.ID) AS ChipAnz
  FROM OPTeile
  WHERE LEN(OPTeile.Code) = 24
    AND OPTeile.Status = N'Q'

  UNION ALL

  SELECT N'UHF' AS Tech, COUNT(Teile.ID) AS ChipAnz
  FROM Teile
  WHERE (LEN(Teile.Barcode) = 24 OR LEN(Teile.RentomatChip) = 24)
    AND Teile.Status = N'Q'

  UNION ALL

  SELECT N'HF' AS Tech, COUNT(OPTeile.ID) AS ChipAnz
  FROM OPTeile
  WHERE LEN(OPTeile.Code) = 16
    AND OPTeile.Status = N'Q'

  UNION ALL

  SELECT N'HF' AS Tech, COUNT(Teile.ID) AS ChipAnz
  FROM Teile
  WHERE (LEN(Teile.Barcode) = 16 OR LEN(Teile.RentomatChip) = 16)
    AND Teile.Status = N'Q'

  UNION ALL

  SELECT N'LF' AS Tech, COUNT(OPTeile.ID) AS ChipAnz
  FROM OPTeile
  WHERE LEN(OPTeile.Code) = 12
    AND OPTeile.Code LIKE N'D00%'
    AND OPTeile.Status = N'Q'

  UNION ALL

  SELECT N'LF' AS Tech, COUNT(Teile.ID) AS ChipAnz
  FROM Teile
  WHERE ((LEN(Teile.Barcode) = 12 AND Teile.Barcode LIKE N'D00%') OR (LEN(Teile.RentomatChip) = 12 AND Teile.RentomatChip LIKE N'D00%'))
    AND Teile.Status = N'Q'
) AS x
GROUP BY x.Tech;

-- Ausgelieferte UHF-Teile pro Woche
SELECT SummeTeile / AnzWochen AS [UHF geliefert]
FROM (
  SELECT COUNT(Woche) AS AnzWochen, SUM([UHF-Teile geliefert]) AS SummeTeile
  FROM (
    SELECT CAST(YEAR(AnfKo.LieferDatum) AS nchar(4)) + N'/' + RIGHT(REPLICATE(N'0', 2) + RTRIM(CAST(DATEPART(WEEK, AnfKo.Lieferdatum) AS nchar(2))), 2) AS Woche, COUNT(OPTeile.ID) AS [UHF-Teile geliefert]
    FROM OPScans
    JOIN OPTeile ON OPScans.OPTeileID = OPTeile.ID
    JOIN AnfPo ON OPScans.AnfPoID = AnfPo.ID
    JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
    WHERE AnfKo.LieferDatum >= N'2018-01-01'
      AND OPScans.AnfPoID > 0
      AND LEN(OPTeile.Code) = 24
    GROUP BY CAST(YEAR(AnfKo.LieferDatum) AS nchar(4)) + N'/' + RIGHT(REPLICATE(N'0', 2) + RTRIM(CAST(DATEPART(WEEK, AnfKo.Lieferdatum) AS nchar(2))), 2)
  ) AS y
) AS x;

-- Anzahl Bekleidungsausgabesystem
SELECT COUNT(*) AS BKS
FROM Rentomat
WHERE Rentomat.ID > 0
  AND Rentomat.Interface IN (N'LCT', N'Unimat', N'DCSvoll')
  AND Rentomat.ID <> 54 -- UKH Linz Test
;