DECLARE @RechArchPath nvarchar(100) = dbo.GetSetting(N'PATH_RECHARCH', N'');

SELECT DISTINCT N'if(!(Test-Path "' + @RechArchPath + LEFT(RechKo.ExtRechNr, 5) + N'")) { New-Item -Path "' + @RechArchPath + LEFT(RechKo.ExtRechNr, 5) + N'" -ItemType Directory -Force | Out-Null }' AS pwshcmd
FROM RechKo
WHERE RechKo.ExtRechNr IS NOT NULL
  AND RechKo.KundenID != 1607498;

SELECT DISTINCT N'Get-ChildItem -Path "' + @RechArchPath + LEFT(RIGHT('000000000000' + CAST(RechKo.RechNr AS nvarchar), 8), 5) + N'" -Filter "' + CAST(RIGHT('000000000000' + CAST(RechKo.RechNr AS nvarchar), 8) AS nvarchar) + N'_*.*" | ForEach-Object { Move-Item -Path $_.FullName -Destination "' + @RechArchPath + LEFT(RechKo.ExtRechNr, 5) + N'\$($_.Name -replace ''' + CAST(RIGHT('000000000000' + CAST(RechKo.RechNr AS nvarchar), 8) AS nvarchar) + N''', ''' + RechKo.ExtRechNr + N''')" }' AS pwshcmd
FROM RechKo
WHERE RechKo.ExtRechNr IS NOT NULL
  AND RechKo.KundenID != 1607498;