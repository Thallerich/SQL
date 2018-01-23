-- Import Benutzer

INSERT INTO WebUser
SELECT GetNextID('WEBUSER') AS ID, UserName, Password, 'A' AS Status, KundenID, FullName, Geschlecht, True AS GrandKundendaten, True AS GrandRechnungen, True AS GrandLS, True AS GrandKdArti, True AS GrandVsa, True AS GrandStationen, True AS GrandTraeger, True AS GrandBewohner, True AS GrandInventur, True AS GrandSuche, True AS GrandMessages, True AS GrandLists, False AS GrandVertraege, False AS GrandVsaTour, True AS GrandKostenstellen, False AS GrandLSFuture, False AS GrandVsaAnf, False AS GrandDocument, False AS InsertAnfKo, False AS AbmeldTraeger, CCeMail AS eMail, '' AS CCeMail, BCCeMail, False AS SendStatusMails, True AS HideIndienst, True AS HideEingang, True AS HideAusgang, False AS HidePreise, True AS HideWaeschen, False AS HideBestellAvg, True AS HideStatistik, True AS HideReparatur, False AS HideKoloKenSchra, True AS HideLieferTermin, True AS HideKaufware, -1 AS LanguageID, True AS FuncAddWearer, True AS FuncChangeSize, True AS FuncChangeAmount, True AS FuncEditWearer, True AS FuncDeactivateW, True AS FuncExcelExport, True AS FuncChangeTraeFach, True AS FuncChangeArtikel, True AS FuncAddTraeArti, True AS FuncPersonalliste, False AS FuncAddVsaAnfEinmal, -1 AS MitarbeiID, True AS ShowLeasPreis, False AS ShowPeriodPreis, False AS MailAnfImport, False AS MailAnfSaved, EncryptedPassword AS UserPassword, NOW() AS Anlage_, NOW() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser_
FROM (
	SELECT UserName, Password, KundenID, FullName, Geschlecht, CCeMail, BCCeMail, Encryptedpassword
  FROM __webuser
  GROUP BY UserName, Password, KundenID, FullName, Geschlecht, CCeMail, BCCeMail, Encryptedpassword
) ewwebuser;


-- Import Kostenstellen-Zuordnung

INSERT INTO WebUAbt
SELECT GetNextID('WEBUABT') AS ID, WebUserID, AbteilID, NOW() AS Anlage_, NOW() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser
FROM ( 
  SELECT Webuser.ID AS WebuserID, ewwebuser.AbteilID
  FROM __webuser ewwebuser, WebUser
  WHERE ewwebuser.UserName = WebUser.UserName
  GROUP BY WebuserID, AbteilID
) ewwebuvsa;