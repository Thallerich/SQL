CREATE OR ALTER VIEW [sapbw].[v_BW_Betreuer] AS
SELECT DISTINCT Initialen =
  CASE
    WHEN Mitarbei.ID < 0 THEN N'??????'
    WHEN Mitarbei.MaNr = N'190002' THEN N'BAYELE'
    WHEN Mitarbei.MaNr = N'231' THEN N'BENNCL'
    WHEN Mitarbei.MaNr = N'189' THEN N'FUERTH'
    WHEN Mitarbei.MaNr = N'3502' THEN N'GRIEWA'
    WHEN Mitarbei.MaNr = N'1' THEN N'KV'
    WHEN Mitarbei.MaNr = N'3404' THEN N'TSCHDA'
    WHEN Mitarbei.MaNr = N'235' THEN Mitarbei.Nachname
    WHEN Mitarbei.MaNr = N'40' THEN N'ZAHRWO'
    WHEN Mitarbei.MaNr IN (N'208', N'3503') THEN N'KOESSA'
    WHEN Mitarbei.Initialen IS NULL AND Mitarbei.UserName IS NULL THEN CAST(Mitarbei.ID AS nvarchar)
    WHEN Mitarbei.Initialen IS NULL AND Mitarbei.UserName IS NOT NULL THEN Mitarbei.UserName
    ELSE UPPER(Mitarbei.Initialen)
  END,
  [Name] = IIF(Mitarbei.ID < 0, N'??????', Mitarbei.[Name])
FROM Salesianer.dbo.Mitarbei
WHERE EXISTS (
  SELECT KdBer.*
  FROM Salesianer.dbo.KdBer
  WHERE KdBer.VertreterID = Mitarbei.ID
);