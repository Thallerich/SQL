SELECT KdNr,
  Kunde,
  Kundenstatus,
  Holding,
  -- Use Wingdings as Font in Excel
  IIF([BK] <> 0, N'þ', N'') AS Berufsbekleidung,
  IIF([BW] <> 0, N'þ', N'') AS Bereichskleidung,
  IIF([CT] <> 0, N'þ', N'') AS Bewohnerwäsche,
  IIF([EW] <> 0, N'þ', N'') AS [Eigenwäsche (ohne BK)],
  IIF([EWB] <> 0, N'þ', N'') AS [Eigenwäsche BK],
  IIF([EWT] <> 0, N'þ', N'') AS [Eigenwäsche Tischwäsche],
  IIF([GE] <> 0, N'þ', N'') AS [Geräte & Sammler],
  IIF([HW] <> 0, N'þ', N'') AS Handelswaren,
  IIF([IK] <> 0, N'þ', N'') AS [Inko-Versorgung],
  IIF([OP] <> 0, N'þ', N'') AS [OP-Textilien],
  IIF([RR] <> 0, N'þ', N'') AS Micronclean,
  IIF([SH] <> 0, N'þ', N'') AS Flachwäsche,
  IIF([SHC] <> 0, N'þ', N'') AS [Flachwäsche codiert],
  IIF([TPS] <> 0, N'þ', N'') AS [Thromboseprophylaxestrümpfe],
  IIF([TW] <> 0, N'þ', N'') AS Tischwäsche,
  IIF([UB] <> 0, N'þ', N'') AS Umsatzboni,
  IIF([VM] <> 0, N'þ', N'') AS Vermietung,
  IIF([WL] <> 0, N'þ', N'') AS Wäschelogistik
FROM (
  SELECT Standort.Bez AS Standort,
    Kunden.KdNr,
    Kunden.SuchCode AS Kunde,
    [Status].StatusBez AS Kundenstatus,
    Holding.Holding,
    Bereich.Bereich
  FROM Kunden
  JOIN KdBer ON KdBer.KundenID = Kunden.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN [Status] ON Kunden.[Status] = [Status].[Status] AND [Status].Tabelle = N'KUNDEN'
  JOIN Holding ON Kunden.HoldingID = Holding.ID
  WHERE Standort.Bez = N'Rankweil'
) AS KdRan
PIVOT (
  COUNT(Bereich)
  FOR Bereich IN ([BK], [BW], [CT], [EW], [EWB], [EWT], [GE], [HW], [IK], [OP], [RR], [SH], [SHC], [TPS], [TW], [UB], [VM], [WL])
) AS Pivot_KdRan;