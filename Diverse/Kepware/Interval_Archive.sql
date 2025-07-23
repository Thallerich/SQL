/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kepware - Script to archive measurements as consumption in an interval of 15 minutes and 1 minute                         ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2025-07-23                                                                                       ++ */
/* ++ Version: 1.2                                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/*
TRUNCATE TABLE KEPWARE_LINZ_CONSUMPTION_15m;
TRUNCATE TABLE KEPWARE_LINZ_CONSUMPTION_1m;
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @msg nvarchar(max), @errormessage nvarchar(max);
DECLARE @severity int, @state smallint;

DROP TABLE IF EXISTS #Kepware_Interval_Archive_15m, #Kepware_Interval_Archive_1m;

/* prepare cumulated interval data (15 minutes and 1 minute intervals) */

SELECT _NAME, _NUMERICID, Timestamp_Interval_15, SUM(TRY_CAST(_VALUE AS decimal) - TRY_CAST(Previous_Value AS decimal)) AS Value_Change_in_Interval
INTO #Kepware_Interval_Archive_15m
FROM (
  SELECT _NAME, _NUMERICID, DATEADD(minute, CEILING((DATEDIFF(minute, N'1900-01-01 00:00:00.000', _TIMESTAMP) + 1) / CAST(15 AS decimal)) * 15, N'1900-01-01 00:00:00.000') AS Timestamp_Interval_15, _VALUE + ISNULL(OverflowValue, 0) AS _VALUE, LAG(_VALUE + ISNULL(OverflowValue, 0), 1, 0) OVER (PARTITION BY _NAME, _NUMERICID ORDER BY _TIMESTAMP ASC) AS Previous_Value
  FROM (
    SELECT KEPWARE_LINZ._NAME, KEPWARE_LINZ._NUMERICID, KEPWARE_LINZ._TIMESTAMP, meter.meter_type_name, KEPWARE_LINZ._VALUE,
    OverflowValue = (
      SELECT TOP 1 KepOverflow._VALUE * OverflowMeter.conversion_factor
      FROM KEPWARE_LINZ AS KepOverflow
      JOIN Puls_Test.dbo.meter AS OverflowMeter ON KepOverflow._NUMERICID = OverflowMeter.id
      WHERE KepOverflow._NUMERICID = meter.helper_meter_id
        AND KepOverflow._TIMESTAMP <= KEPWARE_LINZ._TIMESTAMP
      ORDER BY KepOverflow._TIMESTAMP DESC
    )
    FROM KEPWARE_LINZ
    JOIN Puls_Test.dbo.meter ON KEPWARE_LINZ._NUMERICID = meter.id
    WHERE meter.meter_type_name != N'OVERFLOW'
      AND KEPWARE_LINZ._VALUE != 0
  ) AS CalcMeterData
) AS IntervalData
GROUP BY _NAME, _NUMERICID, Timestamp_Interval_15
ORDER BY Timestamp_Interval_15 DESC;

SELECT _NAME, _NUMERICID, Timestamp_Interval_1, SUM(TRY_CAST(_VALUE AS decimal) - TRY_CAST(Previous_Value AS decimal)) AS Value_Change_in_Interval
INTO #Kepware_Interval_Archive_1m
FROM (
  SELECT _NAME, _NUMERICID, DATEADD(minute, CEILING((DATEDIFF(minute, N'1900-01-01 00:00:00.000', _TIMESTAMP) + 1) / CAST(1 AS decimal)) * 1, N'1900-01-01 00:00:00.000') AS Timestamp_Interval_1, _VALUE + ISNULL(OverflowValue, 0) AS _VALUE, LAG(_VALUE + ISNULL(OverflowValue, 0), 1, 0) OVER (PARTITION BY _NAME, _NUMERICID ORDER BY _TIMESTAMP ASC) AS Previous_Value
  FROM (
    SELECT KEPWARE_LINZ._NAME, KEPWARE_LINZ._NUMERICID, KEPWARE_LINZ._TIMESTAMP, meter.meter_type_name, KEPWARE_LINZ._VALUE,
    OverflowValue = (
      SELECT TOP 1 KepOverflow._VALUE * OverflowMeter.conversion_factor
      FROM KEPWARE_LINZ AS KepOverflow
      JOIN Puls_Test.dbo.meter AS OverflowMeter ON KepOverflow._NUMERICID = OverflowMeter.id
      WHERE KepOverflow._NUMERICID = meter.helper_meter_id
        AND KepOverflow._TIMESTAMP <= KEPWARE_LINZ._TIMESTAMP
        AND KEPWARE_LINZ._VALUE != 0
      ORDER BY KepOverflow._TIMESTAMP DESC
    )
    FROM KEPWARE_LINZ
    JOIN Puls_Test.dbo.meter ON KEPWARE_LINZ._NUMERICID = meter.id
    WHERE meter.meter_type_name != N'OVERFLOW'
  ) AS CalcMeterData
) AS IntervalData
GROUP BY _NAME, _NUMERICID, Timestamp_Interval_1
ORDER BY Timestamp_Interval_1 DESC;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KEPWARE_LINZ_CONSUMPTION_15m SET _CONSUMPTION = #Kepware_Interval_Archive_15m.Value_Change_in_Interval
    FROM #Kepware_Interval_Archive_15m
    WHERE #Kepware_Interval_Archive_15m._NAME = KEPWARE_LINZ_CONSUMPTION_15m._NAME
      AND #Kepware_Interval_Archive_15m._NUMERICID = KEPWARE_LINZ_CONSUMPTION_15m._NUMERICID
      AND #Kepware_Interval_Archive_15m.Timestamp_Interval_15 = KEPWARE_LINZ_CONSUMPTION_15m._TIMESTAMP
      AND #Kepware_Interval_Archive_15m.Value_Change_in_Interval != KEPWARE_LINZ_CONSUMPTION_15m._CONSUMPTION
      AND #Kepware_Interval_Archive_15m.Timestamp_Interval_15 > (SELECT MIN(Timestamp_Interval_15) FROM #Kepware_Interval_Archive_15m);  /* do not update first entry as calculated consumption value is "wrong" since no previous records for calculation exist in source table */

    SELECT @msg = 'Updated ' + CAST(@@ROWCOUNT AS nvarchar) + ' rows in KEPWARE_LINZ_CONSUMPTION_15m.';
    RAISERROR (@msg, 0, 1) WITH NOWAIT;

    INSERT INTO KEPWARE_LINZ_CONSUMPTION_15m (_NAME, _NUMERICID, _TIMESTAMP, _CONSUMPTION)
    SELECT _NAME, _NUMERICID, Timestamp_Interval_15, Value_Change_in_Interval
    FROM #Kepware_Interval_Archive_15m
    WHERE #Kepware_Interval_Archive_15m.Timestamp_Interval_15 <= GETDATE()
      AND NOT EXISTS (
        SELECT 1
        FROM KEPWARE_LINZ_CONSUMPTION_15m
        WHERE KEPWARE_LINZ_CONSUMPTION_15m._NAME = #Kepware_Interval_Archive_15m._NAME
          AND KEPWARE_LINZ_CONSUMPTION_15m._NUMERICID = #Kepware_Interval_Archive_15m._NUMERICID
          AND KEPWARE_LINZ_CONSUMPTION_15m._TIMESTAMP = #Kepware_Interval_Archive_15m.Timestamp_Interval_15
      );

    SELECT @msg = 'Inserted ' + CAST(@@ROWCOUNT AS nvarchar) + ' rows in KEPWARE_LINZ_CONSUMPTION_15m.';
    RAISERROR (@msg, 0, 1) WITH NOWAIT;
  
  COMMIT;
END TRY
BEGIN CATCH
  SELECT @errormessage = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;

  RAISERROR(@errormessage, @severity, @state) WITH NOWAIT;
END CATCH;

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE KEPWARE_LINZ_CONSUMPTION_1m SET _CONSUMPTION = #Kepware_Interval_Archive_1m.Value_Change_in_Interval
    FROM #Kepware_Interval_Archive_1m
    WHERE #Kepware_Interval_Archive_1m._NAME = KEPWARE_LINZ_CONSUMPTION_1m._NAME
      AND #Kepware_Interval_Archive_1m._NUMERICID = KEPWARE_LINZ_CONSUMPTION_1m._NUMERICID
      AND #Kepware_Interval_Archive_1m.Timestamp_Interval_1 = KEPWARE_LINZ_CONSUMPTION_1m._TIMESTAMP
      AND #Kepware_Interval_Archive_1m.Value_Change_in_Interval != KEPWARE_LINZ_CONSUMPTION_1m._CONSUMPTION
      AND #Kepware_Interval_Archive_1m.Timestamp_Interval_1 > (SELECT MIN(Timestamp_Interval_1) FROM #Kepware_Interval_Archive_1m);  /* do not update first entry as calculated consumption value is "wrong" since no previous records for calculation exist in source table */

    SELECT @msg = 'Updated ' + CAST(@@ROWCOUNT AS nvarchar) + ' rows in KEPWARE_LINZ_CONSUMPTION_1m.';
    RAISERROR (@msg, 0, 1) WITH NOWAIT;

    INSERT INTO KEPWARE_LINZ_CONSUMPTION_1m (_NAME, _NUMERICID, _TIMESTAMP, _CONSUMPTION)
    SELECT _NAME, _NUMERICID, Timestamp_Interval_1, Value_Change_in_Interval
    FROM #Kepware_Interval_Archive_1m
    WHERE #Kepware_Interval_Archive_1m.Timestamp_Interval_1 <= GETDATE()
      AND NOT EXISTS (
        SELECT 1
        FROM KEPWARE_LINZ_CONSUMPTION_1m
        WHERE KEPWARE_LINZ_CONSUMPTION_1m._NAME = #Kepware_Interval_Archive_1m._NAME
          AND KEPWARE_LINZ_CONSUMPTION_1m._NUMERICID = #Kepware_Interval_Archive_1m._NUMERICID
          AND KEPWARE_LINZ_CONSUMPTION_1m._TIMESTAMP = #Kepware_Interval_Archive_1m.Timestamp_Interval_1
      );

    SELECT @msg = 'Inserted ' + CAST(@@ROWCOUNT AS nvarchar) + ' rows in KEPWARE_LINZ_CONSUMPTION_1m.';
    RAISERROR (@msg, 0, 1) WITH NOWAIT;
  
  COMMIT;
END TRY
BEGIN CATCH
   SELECT @errormessage = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;

  RAISERROR(@errormessage, @severity, @state) WITH NOWAIT;
END CATCH;

/* cleanup source tables - delete all entries older than 1 month */
--DELETE FROM KEPWARE_LINZ
--WHERE _TIMESTAMP < DATEADD(month, -1, DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)) ; /* start of day one month ago */

DROP TABLE #Kepware_Interval_Archive_15m, #Kepware_Interval_Archive_1m;
GO