/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Insert unknown Chips into Chip table                                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO Chip (EPC, TestDate)
SELECT DISTINCT UPPER(REPLACE(_Run1.EPCValue, N'0x', N'')) AS EPC, CAST(GETDATE() AS date)
FROM _Run1
WHERE NOT EXISTS (
  SELECT Chip.*
  FROM Chip
  WHERE Chip.EPC = UPPER(REPLACE(_Run1.EPCValue, N'0x', N''))
);

GO

INSERT INTO Chip (EPC, TestDate)
SELECT DISTINCT UPPER(REPLACE(_Run2.EPCValue, N'0x', N'')) AS EPC, CAST(GETDATE() AS date)
FROM _Run2
WHERE NOT EXISTS (
  SELECT Chip.*
  FROM Chip
  WHERE Chip.EPC = UPPER(REPLACE(_Run2.EPCValue, N'0x', N''))
);

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Set Chip type                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT DISTINCT EPC
FROM Chip
WHERE Chip.ChipType IS NULL
  AND Chip.TestDate = CAST(GETDATE() AS date);

SELECT DISTINCT ChipType FROM Chip;

GO

UPDATE Chip SET ChipType = N'ThermoTex Sticktransponder F20'
WHERE Chip.EPC LIKE N'E280117000000%';

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Insert test runs into table Testrun                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO Testrun (EPC, [Timestamp], RSSI, [Power], RunNumber)
SELECT UPPER(REPLACE(EPCValue, N'0x', N'')) AS EPC, GETDATE() AS [Timestamp], RSSI, CAST([Power] AS numeric(10, 2)) AS [Power], 3 AS RunNumber
FROM _Run1;

GO

INSERT INTO Testrun (EPC, [Timestamp], RSSI, [Power], RunNumber)
SELECT UPPER(REPLACE(EPCValue, N'0x', N'')) AS EPC, GETDATE() AS [Timestamp], RSSI, CAST([Power] AS numeric(10, 2)) AS [Power], 4 AS RunNumber
FROM _Run2;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Cleanup import tables                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS _Run1;
GO

DROP TABLE IF EXISTS _Run2;
GO