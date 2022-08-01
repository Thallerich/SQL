/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Anpassung Import-Tabelle                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* ALTER TABLE _MaImport ADD StandortID int, FirmaID int, MitarAbtID int;
GO */

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ prepare Import                                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO MitarAbt (MitarAbtBez, MitarAbtBez1, MitarAbtBez2, MitarAbtBez3, MitarAbtBez4, MitarAbtBez5, MitarAbtBez6, MitarAbtBez7, MitarAbtBez8, MitarAbtBez9, MitarAbtBezA, AnlageUserID_, UserID_)
SELECT DISTINCT LEFT(_MaImport.Abteilung, 40), LEFT(_MaImport.Abteilung, 40), LEFT(_MaImport.Abteilung, 40), LEFT(_MaImport.Abteilung, 40), LEFT(_MaImport.Abteilung, 40), LEFT(_MaImport.Abteilung, 40), LEFT(_MaImport.Abteilung, 40), LEFT(_MaImport.Abteilung, 40), LEFT(_MaImport.Abteilung, 40), LEFT(_MaImport.Abteilung, 40), LEFT(_MaImport.Abteilung, 40), @UserID, @UserID
FROM _MaImport
WHERE _MaImport.Abteilung IS NOT NULL
  AND NOT EXISTS (
    SELECT MitarAbt.*
    FROM MitarAbt
    WHERE MitarAbt.MitarAbtBez = _MaImport.Abteilung COLLATE Latin1_General_CS_AS
  );

GO

UPDATE _MaImport SET StandortID = Standort.ID
FROM Standort
WHERE _MaImport.Standort COLLATE Latin1_General_CS_AS = Standort.Bez;

GO

UPDATE _MaImport SET StandortID = -1
WHERE StandortID IS NULL;

GO

UPDATE _MaImport SET FirmaID = Firma.ID
FROM Firma
WHERE _MaImport.Firma COLLATE Latin1_General_CS_AS = Firma.Bez

GO

UPDATE _MaImport SET FirmaID = -1
WHERE FirmaID IS NULL;

GO

UPDATE _MaImport SET MitarAbtID = MitarAbt.ID
FROM MitarAbt
WHERE _MaImport.Abteilung COLLATE Latin1_General_CS_AS = MitarAbt.MitarAbtBez;

GO

UPDATE _MaImport SET MitarAbtID = -1
WHERE MitarAbtID IS NULL;

GO */

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Perform import                                                                                                            ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

BEGIN TRANSACTION;

UPDATE Mitarbei SET Mitarbei.Nachname = _MaImport.Nachname COLLATE Latin1_General_CS_AS,
  Mitarbei.Vorname = _MaImport.Vorname COLLATE Latin1_General_CS_AS,
  Mitarbei.Titel = _MaImport.Titel COLLATE Latin1_General_CS_AS,
  Mitarbei.Name = ISNULL(_MaImport.Nachname, N'') + ISNULL(N', ' + _MaImport.Titel, N'') + ISNULL(N', ' + _MaImport.Vorname, N''),
  Mitarbei.Strasse = _MaImport.Strasse COLLATE Latin1_General_CS_AS,
  Mitarbei.Land = _MaImport.Land COLLATE Latin1_General_CS_AS,
  Mitarbei.PLZ = _MaImport.PLZ COLLATE Latin1_General_CS_AS,
  Mitarbei.Ort = _MaImport.Ort COLLATE Latin1_General_CS_AS,
  Mitarbei.Telefon = dbo.FormatPhoneNo(_MaImport.Telefon) COLLATE Latin1_General_CS_AS,
  Mitarbei.Mobil = dbo.FormatPhoneNo(_MaImport.Mobil) COLLATE Latin1_General_CS_AS,
  Mitarbei.eMail = _MaImport.eMail COLLATE Latin1_General_CS_AS,
  Mitarbei.StandortID = _MaImport.StandortID,
  Mitarbei.FirmaID = _MaImport.FirmaID,
  Mitarbei.MitarAbtID = _MaImport.MitarAbtID,
  Mitarbei.SMTPHost = N'SMWMAIL2.sal.co.at',
  Mitarbei.SMTPUser = UPPER(LEFT(_MaImport.Nachname, 3)) + UPPER(LEFT(_MaImport.Vorname, 2)),
  Mitarbei.SMTPPassword = N'LHISEUMJBIEOKJMPGIMKHRHMNFJUDMFLJGCGFLCGJJETJNGM'
FROM _MaImport
WHERE _MaImport.MitarbeiID = Mitarbei.ID;

COMMIT;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Cleanup                                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* DELETE
FROM MitarAbt
WHERE ID > 0
  AND NOT EXISTS (
    SELECT Mitarbei.*
    FROM Mitarbei
    WHERE Mitarbei.MitarAbtID = MitarAbt.ID
  );

GO

DROP TABLE _MaImport;
GO */