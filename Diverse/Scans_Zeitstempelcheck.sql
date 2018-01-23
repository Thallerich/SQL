SELECT *
FROM (
  SELECT TeileID, ZielNrID, DateTime, Anlage_, TIMESTAMPDIFF(SQL_TSI_HOUR, Anlage_, DateTime) AS Differenz
  FROM Scans
  WHERE CONVERT(Anlage_, SQL_DATE) = CURDATE()
) Diff
WHERE Diff.Differenz <> 0

SELECT TeileID, ZielNrID, DateTime, Anlage_, TIMESTAMPDIFF(SQL_TSI_DAY, Anlage_, DateTime) AS Differenz
FROM Scans
WHERE TIMESTAMPDIFF(SQL_TSI_DAY, Anlage_, DateTime) <> 0