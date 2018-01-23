-- User nicht in Wozabal-Umgebung
SELECT NewID, OldID, [User], Password, UserName, Vorname, Nachname, LastLogin, LastLogout, LoginCount, Mandant, UserGrpID, AutoLogin, BdeUser, ClickLogin, LanguageID, LastNewsID, ShowNews, Anlage_, Update_, User_, Abteilung, eMail, Standort, Telefon, Telefax, Handy, SmtpHost, SmtpUser, SmtpPass, MandantID, CheckWinUser, ExportAllowed, NoWorkflow, Position, Strasse, PLZ, Ort, ReklamMess, ReklamMail, Autorespond, ServicemailMess, CheckForUpdates, PrintPreviewDefault, AdvUserLevel, SqlDebugLevel, OnlyModule, SmtpPassword, ConfigureMode, Barcode
INTO #TmpUUser
FROM (
	SELECT uu.ID AS OldID, ROWNUM()+ (SELECT MAX(ID) FROM dbshared.Users) AS NewID, uu.*
	FROM "\\atenadvtest02\advumgebung\umlauft\data\shared\ddshared.add".Users uu
	LEFT OUTER JOIN dbshared.Users uw ON uu.[User] = uw.[User]
	WHERE uw.[User] IS NULL
		AND uu.LastLogin IS NOT NULL
		AND CONVERT(uu.LastLogin, SQL_DATE) > '30.11.2011'
) UserData;

-- User in Wozabal-Shared einfügen
INSERT INTO dbshared.Users
SELECT NewID, [User], Password, UserName, Vorname, Nachname, LastLogin, LastLogout, LoginCount, Mandant, UserGrpID, AutoLogin, BdeUser, ClickLogin, LanguageID, LastNewsID, ShowNews, Anlage_, Update_, User_, Abteilung, eMail, Standort, Telefon, Telefax, Handy, SmtpHost, SmtpUser, SmtpPass, MandantID, CheckWinUser, ExportAllowed, NoWorkflow, Position, Strasse, PLZ, Ort, ReklamMess, ReklamMail, Autorespond, ServicemailMess, CheckForUpdates, PrintPreviewDefault, AdvUserLevel, SqlDebugLevel, OnlyModule, SmtpPassword, ConfigureMode, Barcode
FROM #TmpUUser;

-- UsrInGrp Benutzergruppenzuordnung für oben importierte Benutzer übernehmen
INSERT INTO dbshared.UsrInGrp
SELECT tuu.NewID AS UsersID, uuig.UserGrpID, ROWNUM() + (SELECT MAX(ID) FROM dbshared.UsrInGrp) AS ID
FROM #TmpUUser tuu, "\\atenadvtest02\advumgebung\umlauft\data\shared\ddshared.add".UsrInGrp uuig
WHERE uuig.UsersID = tuu.OldID;

-- Rechte-Funktionen-Zuordnung nicht in Wozabal-Umgebung
INSERT INTO dbshared.ModAct
SELECT mu.*
FROM "\\atenadvtest02\advumgebung\umlauft\data\shared\ddshared.add".ModAct mu
LEFT OUTER JOIN dbshared.ModAct mw ON mw.[Module]+mw.[Action]+CONVERT(mw.RightsID, SQL_VARCHAR) = mu.[Module]+mu.[Action]+CONVERT(mu.RightsID, SQL_VARCHAR)
WHERE mw.RightsID IS NULL;

-- Rechte und Gruppen in beiden Mandanten gleich.

-- 10er-Menü Köpfe
SELECT NewID, OldID, Bez, Pos, Benutzer, ModulName, ShortCut, ImageIndex, Anlage_, User_, Update_
INTO #TmpUUsrMnuK10
FROM (
	SELECT u10k.ID AS OldID, ROWNUM() + (SELECT MAX(ID) FROM dbshared.UsrMnuK10) AS NewID, u10k.* 
	FROM "\\atenadvtest02\advumgebung\Umlauft\data\shared\ddshared.add".UsrMnuK10 u10k
	LEFT OUTER JOIN dbshared.UsrMnuK10 w10k ON u10k.Bez = w10k.Bez
	WHERE w10k.ID IS NULL 
		OR u10k.ID = 52
) UsrMnuK10Data;

INSERT INTO dbshared.UsrMnuK10
SELECT NewID AS ID, Bez, Pos, Benutzer, ModulName, Shortcut, ImageIndex, Anlage_, User_, Update_
FROM #TmpUUsrMnuK10 uumk10;

-- 10er-Menü Positionen
INSERT INTO dbshared.UsrMnuP10
SELECT NewID AS ID, NewMnuKID AS UsrMnuK10ID, Pos, ModulName, Bez, ImageIndex, Shortcut, Anlage_, User_, Update_
FROM (
	SELECT uump10.ID AS OldID, ROWNUM() + (SELECT MAX(ID) FROM dbshared.UsrMnuP10) AS NewID, uumk10.OldID AS OldMnuKID, uumk10.NewID AS NewMnuKID, uump10.*
	FROM "\\atenadvtest02\advumgebung\Umlauft\data\shared\ddshared.add".UsrMnuP10 uump10, #TmpUUsrMnuK10 uumk10
	WHERE uump10.UsrMnuK10ID = uumk10.OldID
) UUsrMnuP10;

-- Liste geänderter IDs und damit Verknüpfungsparamter (USRMENU_[ID]) für Umlauft
SELECT * FROM #TmpUUsrMnuK10;


-- Terminalserver-User Verknüpfung ändern (10er-Menü)
	kl-car01  USRMENU_52
	kl-ein01  USRMENU_80
	kl-ein02  USRMENU_80
	kl-ste08  USRMENU_56
	kl-ste07  USRMENU_50
	kl-ste06  USRMENU_51
	kl-ste05  USRMENU_51
	kl-ste04  USRMENU_51
	kl-ste02  USRMENU_51
	