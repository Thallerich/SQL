CREATE OR ALTER VIEW [sapbw].[V_BW_FIRMA] AS
  SELECT SuchCode = 
    CASE Firma.SuchCode
      WHEN N'12' THEN N'MPZ'
      WHEN N'21' THEN N'TXS'
      WHEN N'31' THEN N'MBK'
      WHEN N'41' THEN N'LOG'
      WHEN N'42' THEN N'BHG'
      WHEN N'81' THEN N'MAN'
      WHEN N'91' THEN N'GAS'
      ELSE Firma.SuchCode
    END,
    Firma.Bez,
    Firma.Land
  FROM Salesianer.dbo.Firma
  WHERE Firma.ID > 0;