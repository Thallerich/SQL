/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* Stichtag für Bereinigung von Alt-Lasten; alle Container vor diesem Datum werden vom Kunden entlastet                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @Stichtag date = N'2019-12-01';

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kunden-Tabelle aufbauen; diese Kunden sollen Containermiete (ohne Preis) auf der Rechnung bekommen                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @Kunden TABLE (
  KundenID int
);

INSERT INTO @Kunden (KundenID)
SELECT Kunden.ID AS KundenID
FROM Kunden
WHERE Kunden.KdNr IN (1054, 1150, 1157, 1162, 2050, 2118, 2120, 2121, 2122, 2130, 2140, 2160, 2161, 2207, 2304, 4063, 5040, 5062, 6043, 7031, 7033, 7034, 7041, 7048, 7049, 7070, 7073, 7077, 7080, 7081, 7083, 7090, 7100, 7110, 7130, 7135, 7139, 7140, 7150, 7155, 7156, 7157, 7160, 7161, 7162, 7170, 7180, 7235, 7237, 7238, 7239, 8035, 8120, 8130, 8225, 8231, 10040, 10053, 10057, 11040, 11062, 11063, 11082, 11083, 11200, 12040, 12049, 12050, 12051, 12054, 12056, 12071, 12081, 12150, 12160, 13362, 13398, 13425, 15036, 18048, 19037, 19039, 19110, 19120, 19131, 19150, 20036, 20037, 21033, 21087, 21116, 21142, 22051, 24001, 24036, 25075, 25111, 25801, 30035, 30076, 30077, 30090, 30103, 30104, 30116, 30131, 30142, 30153, 30188, 30190, 30192, 30197, 30198, 30214, 30232, 30246, 30255, 30271, 30297, 30321, 30353, 30359, 30397, 30400, 30414, 30423, 30425, 30427, 30438, 30444, 30466, 30493, 30499, 30501, 30505, 30507, 30516, 30520, 30530, 30544, 30549, 30550, 30552, 30553, 30560, 30566, 30568, 30569, 30576, 30577, 30597, 30607, 30609, 30610, 30626, 30628, 30658, 30673, 30689, 30690, 30770, 30783, 30799, 30835, 30903, 30915, 30917, 30918, 30927, 30928, 30933, 30945, 30947, 30959, 30961, 30963, 30975, 31001, 31015, 31018, 31019, 31020, 31024, 31025, 31028, 31032, 31035, 31038, 31040, 31072, 31084, 31093, 31094, 31096, 31099, 31104, 31109, 31127, 31136, 31143, 31147, 31149, 31150, 31151, 31152, 31153, 31155, 31156, 31157, 31158, 31161, 31163, 31166, 31167, 31180, 31181, 31183, 31185, 31198, 31213, 31214, 31215, 31217, 31218, 31219, 31220, 31221, 31223, 31225, 31232, 31233, 31234, 31235, 31236, 31237, 31239, 31245, 31247, 31252, 31253, 31254, 31255, 31257, 31263, 31264, 31265, 31266, 31270, 31271, 31273, 31274, 31275, 31277, 31278, 31281, 31284, 31285, 31286, 31401, 31402, 31403, 31404, 31405, 31407, 31409, 31410, 31411, 31412, 31413, 31414, 31415, 31416, 31417, 31418, 31419, 31420, 31421, 31422, 31423, 31424, 31425, 31426, 31427, 31428, 31429, 31430, 31432, 31433, 31434, 31435, 31436, 32148, 40086, 242638, 244051, 246793, 271709, 2340085, 2340090, 2340092, 2340097, 2340098, 2340102, 2340107, 2340108, 2340109, 2340110, 2340113, 2340114, 2340115, 2340116, 2340117, 2340118, 2340119, 2340120, 2340121, 2340122, 2340123, 2340124, 2340126, 2340127, 2340128, 2340130, 2340131, 2340132, 2340134, 2340136, 10003247, 10004627, 10004631, 10004676, 10004711);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kundenbereich Sonstiges anlegen, falls noch nicht vorhanden                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
 
DECLARE @BereichID int = (SELECT ID FROM Bereich WHERE Bereich.Bereich = N'SE');
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE MitarbeiUser = N'THALST');

DECLARE @InsertedKdBer TABLE (
  KdBerID int,
  KundenID int,
  VertragID int,
  ServiceID int,
  VertreterID int,
  BetreuerID int
);

INSERT INTO KdBer ([Status], KundenID, BereichID, VertragID, FakFreqID, ServiceID, VertreterID, BetreuerID, RechKoServiceID, AnfAusEpo, AnlageUserID_, UserID_)
OUTPUT INSERTED.ID AS KdBerID, INSERTED.KundenID, INSERTED.VertragID, INSERTED.ServiceID, INSERTED.VertreterID, INSERTED.BetreuerID
INTO @InsertedKdBer
SELECT N'A' AS [Status], Kunden.ID AS KundenID, @BereichID AS BereichID, VertragID = (
    SELECT TOP 1 Vertrag.ID
    FROM Vertrag
    WHERE Vertrag.BereichID IN (-1, @BereichID)
      AND Vertrag.Status = N'A'
      AND Vertrag.KundenID = Kunden.ID
    ORDER BY Vertrag.Anlage_ DESC
  ), FakFreqID = (
    SELECT TOP 1 KdBer.FakFreqID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.FakFreqID
    ORDER BY COUNT(KdBer.ID)
  ), ServiceID = (
    SELECT TOP 1 KdBer.ServiceID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.ServiceID
    ORDER BY COUNT(KdBer.ID)
  ), VertreterID = (
    SELECT TOP 1 KdBer.VertreterID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.VertreterID
    ORDER BY COUNT(KdBer.ID)    
  ), BetreuerID = (
    SELECT TOP 1 KdBer.BetreuerID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.BetreuerID
    ORDER BY COUNT(KdBer.ID)
  ), RechKoServiceID = (
    SELECT TOP 1 KdBer.RechKoServiceID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.RechKoServiceID
    ORDER BY COUNT(KdBer.ID)
  ),
  0 AS AnfAusEPo, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM Kunden
WHERE Kunden.ID IN (SELECT KundenID FROM @Kunden)
  AND NOT EXISTS (
    SELECT KdBer.*
    FROM KdBer
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE Bereich.Bereich = N'SE'
      AND KdBer.KundenID = Kunden.ID
  );

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ VSA-Bereiche anlegen bei allen VSAs der Kunden, für die im vorigen Schritt der Kundenbereich angelegt wurde               ++ */
/* ++ TODO: VSA-Bereich auch bei Kunden anlegen, wo der Kundenbereich bereits existierte,                                       ** */
/* ++       aber bei einigen VSAs der Bereich fehlt                                                                             ** */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO VsaBer ([Status], VsaID, KdBerID, VertragID, ServiceID, VertreterID, BetreuerID, AnfAusEpo, VsaTourUnnoetig, ErstFakLeas, ErstLS, AnlageUserID_, UserID_)
SELECT N'A' AS [Status], Vsa.ID AS VsaID, InsertedKdBer.KdBerID, InsertedKdBer.VertragID, InsertedKdBer.ServiceID, InsertedKdBer.VertreterID, InsertedKdBer.BetreuerID, 0 AS AnfAusEPo, 1 AS VsaTourUnnoetig, N'1980/01' AS ErstFakLeas, N'1980/01' AS ErstLs, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM @InsertedKdBer AS InsertedKdBer
JOIN Vsa ON InsertedKdBer.KundenID = Vsa.KundenID
WHERE Vsa.[Status] = N'A';

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Spezialartikel CONTMIET mit Preis = 0 als Kundenartikel anlegen, falls noch nicht vorhanden                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @ArtikelID int = (SELECT ID FROM Artikel WHERE ArtikelNr = N'CONTMIET');

INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, LiefArtID, KostenlosRPo, WebArtikel, AnlageUserID_, UserID_)
SELECT N'A' AS [Status], Kunden.ID AS KundenID, @ArtikelID AS ArtikelID, KdBer.ID AS KdBerID, 4 AS LiefArtID, 1 AS KostenlosRPo, 0 AS WebArtikel, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM Kunden
JOIN KdBer ON KdBer.KundenID = Kunden.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE Kunden.ID IN (SELECT KundenID FROM @Kunden)
  AND Bereich.Bereich = N'SE'
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.KundenID = Kunden.ID
      AND KdArti.ArtikelID = @ArtikelID
  );

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Altlasten bereinigen -> Container die vor Stichtag beim Kunden abgeladen wurden, vom Kunden nehmen                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE Contain SET KundenID = -1
WHERE ID IN (
  SELECT Contain.ID AS ContainID
  FROM (
    SELECT ID, KundenID, Ausgang
    FROM CONTAIN
    WHERE KundenID IN (SELECT KundenID FROM @Kunden)
    ) CT
  JOIN ContHist ON CT.KundenID = ContHist.KundenID AND CT.ID = ContHist.ContainID
  JOIN Contain ON CT.ID = Contain.ID
  JOIN Artikel ON Contain.ArtikelID = Artikel.ID
  LEFT JOIN Vsa ON Vsa.ID = ContHist.VsaID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Abteil ON Vsa.AbteilID = Abteil.ID
  WHERE ContHist.Zeitpunkt > CT.Ausgang
    AND CAST(ContHist.Zeitpunkt AS DATE) <= @Stichtag
    AND ContHist.STATUS = 'e'
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Modulaufruf für Wiederholung der Wochenabschlüsse ausgeben → Im AdvanTex ausführen                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT N'CLOSEWEEK;' + Wochen.Woche + ';' + CAST(Kunden.KundenID AS nvarchar) AS ModuleCall
FROM @Kunden AS Kunden
CROSS JOIN Week
JOIN Wochen ON Week.Woche = Wochen.Woche
WHERE Week.BisDat <= CAST(GETDATE() AS date)
  AND Wochen.Monat1 = N'2020-02';