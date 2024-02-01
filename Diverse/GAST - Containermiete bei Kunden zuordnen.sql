/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* Stichtag für Bereinigung von Alt-Lasten; alle Container vor diesem Datum werden vom Kunden entlastet                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @Stichtag date = N'2019-12-01';

DECLARE @ArtikelID int, @BereichID int;
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE MitarbeiUser = N'THALST');
SELECT @ArtikelID = ID, @BereichID = BereichID FROM Artikel WHERE ArtikelNr = N'CONTMIET';

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kunden-Tabelle aufbauen; diese Kunden sollen Containermiete (ohne Preis) auf der Rechnung bekommen                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @Kunden TABLE (
  KundenID int
);

INSERT INTO @Kunden (KundenID)
SELECT Kunden.ID AS KundenID
FROM Kunden
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE EXISTS (
    SELECT VsaTour.*
    FROM VsaTour
    JOIN Vsa ON VsaTour.VsaID = Vsa.ID
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    JOIN Fahrzeug ON Touren.FahrzeugID = Fahrzeug.ID
    WHERE Vsa.KundenID = Kunden.ID
      AND Fahrzeug.Interface = 1
      AND CAST(GETDATE() AS date) < VsaTour.BisDatum
      AND Touren.Tour != N'#Test'
  )
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.ArtikelID = @ArtikelID
      AND KdArti.KundenID = Kunden.ID
  )
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
  )
  AND Standort.SuchCode IN (N'WOEN', N'WOLI');
  

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kundenbereich Sonstiges anlegen, falls noch nicht vorhanden                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

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
    WHERE KdBer.BereichID = @BereichID
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

INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, LiefArtID, KostenlosRPo, WebArtikel, AnlageUserID_, UserID_)
SELECT N'A' AS [Status], Kunden.ID AS KundenID, @ArtikelID AS ArtikelID, KdBer.ID AS KdBerID, 4 AS LiefArtID, 1 AS KostenlosRPo, 0 AS WebArtikel, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM Kunden
JOIN KdBer ON KdBer.KundenID = Kunden.ID
WHERE Kunden.ID IN (SELECT KundenID FROM @Kunden)
  AND KdBer.BereichID = @BereichID
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.KundenID = Kunden.ID
      AND KdArti.ArtikelID = @ArtikelID
  );

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Altlasten bereinigen -> Container die vor Stichtag beim Kunden abgeladen wurden, vom Kunden nehmen                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* UPDATE Contain SET KundenID = -1
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
); */

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Modulaufruf für Wiederholung der Wochenabschlüsse ausgeben → Im AdvanTex ausführen                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* SELECT N'CLOSEWEEK;' + Wochen.Woche + ';' + CAST(Kunden.KundenID AS nvarchar) AS ModuleCall
FROM @Kunden AS Kunden
CROSS JOIN Week
JOIN Wochen ON Week.Woche = Wochen.Woche
WHERE Week.BisDat <= CAST(GETDATE() AS date)
  AND Wochen.Monat1 = N'2020-02'; */