-- ##### Kostenstellen bei Trägern wiederherstellen #####---
DECLARE @KdNr int = 31066;


-- falsch, nicht verwenden! schreibt AbteilID vom alten Kunden!
UPDATE Wozabal.dbo.Traeger SET AbteilID = TT.AbteilID
FROM Wozabal.dbo.Traeger
JOIN Wozabal_Test.dbo.Traeger AS TT ON TT.ID = Traeger.ID
JOIN Wozabal.dbo.Vsa ON Traeger.VsaID = Vsa.ID
JOIN Wozabal.dbo.Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = @KdNr;

GO

-- ##### DCS - Datenänderung ############################---
DECLARE @Mapping TABLE (KdNrAlt int, KdNrNeu int);

INSERT INTO @Mapping VALUES
--  (2523283, 31063);
--  (2523284, 31064);
--  (2523285, 31065);
  (2523298, 31066);

UPDATE Rentomat SET KundenID = (SELECT Kunden.ID FROM Kunden JOIN @Mapping ON KdNrNeu = KdNr)
WHERE Rentomat.KundenID = (SELECT Kunden.ID FROM Kunden JOIN @Mapping ON KdNrAlt = KdNr)

UPDATE KdAussta SET KdAussta.KundenID = (SELECT Kunden.ID FROM Kunden JOIN @Mapping ON KdNrNeu = KdNr)
WHERE KdAussta.KundenID = (SELECT Kunden.ID FROM Kunden JOIN @Mapping ON KdNrAlt = KdNr)

UPDATE KdAusArt SET KdArtiID = KdArtiNeu.ID
FROM KdAusArt
JOIN KdAussta ON KdAusArt.KdAusstaID = KdAussta.ID AND KdAussta.KundenID = (SELECT Kunden.ID FROM Kunden JOIN @Mapping ON KdNrNeu = KdNr)
JOIN KdArti AS KdArtiAlt ON KdAusArt.KdArtiID = KdArtiAlt.ID
JOIN KdArti AS KdArtiNeu ON KdArtiAlt.ArtikelID = KdArtiNeu.ArtikelID AND KdArtiNeu.KundenID = (SELECT Kunden.ID FROM Kunden JOIN @Mapping ON KdNrNeu = KdNr)

GO

-- ##### Webportal-User übertragen ######################---
DECLARE @Mapping TABLE (KdNrAlt int, KdNrNeu int);

INSERT INTO @Mapping VALUES
--  (2523283, 31063);
--  (2523284, 31064);
--  (2523285, 31065);
  (2523298, 31066);

UPDATE WebUAbt SET AbteilID = AbteilNeu.ID
FROM WebUAbt
JOIN WebUser ON WebUAbt.WebUserID = WebUser.ID
JOIN Abteil ON WebUAbt.AbteilID = Abteil.ID
JOIN Kunden ON WebUser.KundenID = Kunden.ID AND Kunden.KdNr = (SELECT KdNrAlt FROM @Mapping)
JOIN Abteil AS AbteilNeu ON AbteilNeu.Abteilung = Abteil.Abteilung AND AbteilNeu.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = (SELECT KdNrNeu FROM @Mapping));

UPDATE WebUVsa SET VsaID = VsaNeu.ID
FROM WebUVsa
JOIN WebUser ON WebUVsa.WebUserID = WebUser.ID
JOIN Vsa ON WebUVsa.VsaID = Vsa.ID
JOIN Kunden ON WebUser.KundenID = Kunden.ID AND Kunden.KdNr = (SELECT KdNrAlt FROM @Mapping)
JOIN Vsa AS VsaNeu ON VsaNeu.VsaNr = Vsa.VsaNr AND VsaNeu.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = (SELECT KdNrNeu FROM @Mapping));

UPDATE WebUser SET KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = (SELECT KdNrNeu FROM @Mapping))
WHERE WebUser.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = (SELECT KdNrAlt FROM @Mapping));

GO