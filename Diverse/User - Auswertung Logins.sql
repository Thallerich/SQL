SELECT DISTINCT [Windows-User], [letzter Login]
FROM (
  SELECT LoginLog.WindowsUserName AS [Windows-User], MAX(LoginLog.LogInZeit) AS [letzter Login]
  FROM Salesianer.dbo.LoginLog
  JOIN Salesianer.dbo.ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
  JOIN Salesianer.dbo.Mitarbei ON LoginLog.UserID = Mitarbei.ID
  WHERE LoginLog.LogInZeit > N'2020-12-01 00:00:00'
    AND LoginLog.WindowsUserName != N'svc_AdvantexAdmin'
  GROUP BY LoginLog.WindowsUserName

  UNION ALL

  SELECT LoginLog.WindowsUserName AS [Windows-User], MAX(LoginLog.LogInZeit) AS [letzter Login]
  FROM Salesianer_Test.dbo.LoginLog
  JOIN Salesianer_Test.dbo.ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
  JOIN Salesianer_Test.dbo.Mitarbei ON LoginLog.UserID = Mitarbei.ID
  WHERE LoginLog.LogInZeit > N'2020-12-01 00:00:00'
    AND LoginLog.WindowsUserName != N'svc_AdvantexAdmin'
  GROUP BY LoginLog.WindowsUserName

  UNION ALL

  SELECT LoginLog.WindowsUserName AS [Windows-User], MAX(LoginLog.LogInZeit) AS [letzter Login]
  FROM OWS.dbo.LoginLog
  JOIN OWS.dbo.ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
  JOIN OWS.dbo.Mitarbei ON LoginLog.UserID = Mitarbei.ID
  WHERE LoginLog.LogInZeit > N'2020-12-01 00:00:00'
    AND LoginLog.WindowsUserName != N'svc_AdvantexAdmin'
  GROUP BY LoginLog.WindowsUserName
) AS LoginLog
GROUP BY [Windows-User], [letzter Login];

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2021-01-05                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT [Windows-User], MAX([letzter Login])
FROM (
  SELECT LoginLog.WindowsUserName AS [Windows-User], MAX(LoginLog.LogInZeit) AS [letzter Login]
  FROM Salesianer.dbo.LoginLog
  JOIN Salesianer.dbo.ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
  JOIN Salesianer.dbo.Mitarbei ON LoginLog.UserID = Mitarbei.ID
  WHERE LOWER(LoginLog.WindowsUserName) IN (N'techli', N'michur', N'kovves', N'rohrma', N'leogbm1', N'cit-gp-fwsh-cod01', N'karldo', N'smkr-gate-in', N'vollth', N'wmle-naehen1', N'ctxtest.sa', N'kl-ste11', N'sawrleg9', N'leogueb1', N'begiib', N'tmclenzing', N'sander', N'tsatemp01', N'smpkon2', N'kl-lag02', N'pribal', N'usmpte', N'smwnb', N'tirith', N'slobbo', N'marxka', N'smplag1', N'hollma', N'biedst', N'hofehi', N'arndch', N'adv-ows-uz01', N'loepta', N'hofeno', N'khudma', N'eckepe', N'schwzo', N'kallmi', N'krizlu', N'untepe', N'lageruhf3', N'smsklag1', N'lagein2', N'adv-ows-metrik01', N'en-rr-pt03', N'sawrexp5', N'kronma', N'sawrueb3', N'hasllu', N'wva.lkstockerau', N'talosi', N'umkl-bm2', N'smhrexp12', N'blazpa', N'mrnamo', N'veljve', N'kramexp2', N'kriean', N'fuerth', N'kroero', N'deutma', N'sawrleg7', N'weidsu', N'expedit-leog2', N'kl-rep01', N'piesexp2', N'sawrsteril2', N'mocimo', N'nieder', N'smskexp14', N'gallst', N'smhrexp10', N'hajkre', N'smbwueb2', N'smpexp1', N'smskexp15', N'oswama', N'schoda', N'molcth', N'leoglag1', N'smsueb1', N'osmabeadm', N'grazlag2', N'schege', N'wmle-naehen3', N'sawrbesprechungszimm', N'smllkardex2', N'packenmpz2', N'schihe', N'z.zajickova', N'smslexp8', N'smlllagezu3', N'us-micronclean', N'smkr-exp1', N'matead', N'l', N'wmle-naehen2', N'ottolag1', N'en-rr-gt09', N'beneiv', N'ragama', N'kropma', N'sabahu', N'migsma', N'platmi', N'rescwe', N'donama', N'sawrueb1', N'smsexp3', N'eiseja', N'adv-ows-rz01', N'ibiske', N'cavkde', N'hoefma', N'trivniadm', N'magyma', N'sa22l2', N'prijem', N'haasge', N'leogbm2', N'sladne', N'fuitjo', N'griewa', N'adv-ows-sortierung01', N'aueranadm', N'platmiadm')
  GROUP BY LoginLog.WindowsUserName

  UNION ALL

  SELECT LoginLog.WindowsUserName AS [Windows-User], MAX(LoginLog.LogInZeit) AS [letzter Login]
  FROM OWS.dbo.LoginLog
  JOIN OWS.dbo.ArbPlatz ON LoginLog.ArbPlatzID = ArbPlatz.ID
  JOIN OWS.dbo.Mitarbei ON LoginLog.UserID = Mitarbei.ID
  WHERE LOWER(LoginLog.WindowsUserName) IN (N'techli', N'michur', N'kovves', N'rohrma', N'leogbm1', N'cit-gp-fwsh-cod01', N'karldo', N'smkr-gate-in', N'vollth', N'wmle-naehen1', N'ctxtest.sa', N'kl-ste11', N'sawrleg9', N'leogueb1', N'begiib', N'tmclenzing', N'sander', N'tsatemp01', N'smpkon2', N'kl-lag02', N'pribal', N'usmpte', N'smwnb', N'tirith', N'slobbo', N'marxka', N'smplag1', N'hollma', N'biedst', N'hofehi', N'arndch', N'adv-ows-uz01', N'loepta', N'hofeno', N'khudma', N'eckepe', N'schwzo', N'kallmi', N'krizlu', N'untepe', N'lageruhf3', N'smsklag1', N'lagein2', N'adv-ows-metrik01', N'en-rr-pt03', N'sawrexp5', N'kronma', N'sawrueb3', N'hasllu', N'wva.lkstockerau', N'talosi', N'umkl-bm2', N'smhrexp12', N'blazpa', N'mrnamo', N'veljve', N'kramexp2', N'kriean', N'fuerth', N'kroero', N'deutma', N'sawrleg7', N'weidsu', N'expedit-leog2', N'kl-rep01', N'piesexp2', N'sawrsteril2', N'mocimo', N'nieder', N'smskexp14', N'gallst', N'smhrexp10', N'hajkre', N'smbwueb2', N'smpexp1', N'smskexp15', N'oswama', N'schoda', N'molcth', N'leoglag1', N'smsueb1', N'osmabeadm', N'grazlag2', N'schege', N'wmle-naehen3', N'sawrbesprechungszimm', N'smllkardex2', N'packenmpz2', N'schihe', N'z.zajickova', N'smslexp8', N'smlllagezu3', N'us-micronclean', N'smkr-exp1', N'matead', N'l', N'wmle-naehen2', N'ottolag1', N'en-rr-gt09', N'beneiv', N'ragama', N'kropma', N'sabahu', N'migsma', N'platmi', N'rescwe', N'donama', N'sawrueb1', N'smsexp3', N'eiseja', N'adv-ows-rz01', N'ibiske', N'cavkde', N'hoefma', N'trivniadm', N'magyma', N'sa22l2', N'prijem', N'haasge', N'leogbm2', N'sladne', N'fuitjo', N'griewa', N'adv-ows-sortierung01', N'aueranadm', N'platmiadm')
  GROUP BY LoginLog.WindowsUserName
) AS LastLoginLog
GROUP BY [Windows-User], [letzter Login];