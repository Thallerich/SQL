DECLARE @LastMaxSessions int = (SELECT LoginUse.AnzSessions FROM LoginUse WHERE LoginUse.Datum = CAST(DATEADD(day, -1, GETDATE()) AS date) AND LoginUse.[Type] = 1);

IF @LastMaxSessions >= 840 /* aktuelle Lizenzanzahl -10 als Puffer! */
BEGIN
  SELECT LoginUse.Datum, LoginUse.AnzSessions
  FROM LoginUse
  WHERE LoginUse.Datum BETWEEN CAST(DATEADD(day, -7, GETDATE()) AS date) AND CAST(DATEADD(day, -1, GETDATE()) AS date)
    AND LoginUse.[Type] = 1
  ORDER BY Datum DESC;
END;