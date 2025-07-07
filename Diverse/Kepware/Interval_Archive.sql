SELECT _NAME, _NUMERICID, Timestamp_Interval_15, SUM(TRY_CAST(_VALUE AS decimal) - TRY_CAST(Previous_Value AS decimal)) AS Value_Change_in_Interval
FROM (
  SELECT _NAME, _NUMERICID, DATEADD(minute, CEILING(DATEDIFF(minute, N'1900-01-01 00:00:00.000', _TIMESTAMP) / CAST(15 AS decimal)) * 15, N'1900-01-01 00:00:00.000') AS Timestamp_Interval_15, _VALUE, LAG(_VALUE, 1, 0) OVER (PARTITION BY _NAME, _NUMERICID ORDER BY _TIMESTAMP ASC) AS Previous_Value
  FROM KEPWARE_LINZ
) AS IntervalData
GROUP BY _NAME, _NUMERICID, Timestamp_Interval_15
ORDER BY Timestamp_Interval_15 DESC;

GO