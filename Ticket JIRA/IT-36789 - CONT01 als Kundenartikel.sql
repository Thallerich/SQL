DECLARE @Artikel nchar(15) = N'CONT01';
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE MitarbeiUser = N'THALST');

DECLARE @ArtikelID int = (SELECT ID FROM Artikel WHERE ArtikelNr = @Artikel);
DECLARE @BereichID int = (SELECT BereichID FROM Artikel WHERE ID = @ArtikelID);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kunden-Tabelle aufbauen; diese Kunden sollen Containermiete (ohne Preis) auf der Rechnung bekommen                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @Kunden TABLE (
  KundenID int
);

INSERT INTO @Kunden (KundenID)
SELECT DISTINCT Kunden.ID
FROM Touren
JOIN VsaTour ON VsaTour.TourenID = Touren.ID
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE (Touren.Tour LIKE N'4-_41-_' OR Touren.Tour LIKE N'4-_44-_' OR Touren.Tour LIKE N'4-_45-_' OR Touren.Tour LIKE N'4-_47-_')
  AND Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.ArtikelID = @ArtikelID
      AND KdArti.KundenID = Kunden.ID
  )
  AND EXISTS (
    SELECT Vertrag.*
    FROM Vertrag
    WHERE Vertrag.KundenID = Kunden.ID
      AND Vertrag.BereichID IN (-1, @BereichID)
      AND Vertrag.Status = N'A'
  );

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kundenbereich anlegen, falls noch nicht vorhanden                                                                         ++ */
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
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE Bereich.ID = @BereichID
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
/* ++ Kundenartikel anlegen, falls noch nicht vorhanden                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, LiefArtID, KostenlosRPo, WebArtikel, AnlageUserID_, UserID_)
SELECT N'A' AS [Status], Kunden.ID AS KundenID, @ArtikelID AS ArtikelID, KdBer.ID AS KdBerID, 82 AS LiefArtID, 0 AS KostenlosRPo, 0 AS WebArtikel, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM Kunden
JOIN KdBer ON KdBer.KundenID = Kunden.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE Kunden.ID IN (SELECT KundenID FROM @Kunden)
  AND Bereich.ID = @BereichID
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.KundenID = Kunden.ID
      AND KdArti.ArtikelID = @ArtikelID
  );

SELECT * FROM Kunden WHERE ID IN (SELECT KundenID FROM @Kunden);