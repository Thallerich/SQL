UPDATE SichtUsr SET Sehen = 1
FROM SichtUsr
JOIN Mitarbei ON SichtUsr.UserID = Mitarbei.ID
WHERE SichtUsr.SichtbarID = 109
  AND SichtUsr.Sehen = 0
  AND Mitarbei.Status = N'A'
  AND EXISTS (
    SELECT SU.*
    FROM SichtUsr SU
    WHERE SU.UserID = SichtUsr.UserID
      AND SU.SichtbarID IN (2, 76)
      AND SU.Sehen = 1
  )