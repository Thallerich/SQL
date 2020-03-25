DECLARE @ZUS TABLE (
  KundenID int,
  WaschPreis money
);

DECLARE @ZUSInserted TABLE (
  KdArtiID int,
  KundenID int,
  ArtikelID int,
  WaschPreis money
);

DECLARE @KdBerInserted TABLE (
  KdBerID int,
  KundenID int,
  VertragID int,
  ServiceID int,
  VertreterID int,
  BetreuerID int
);

DECLARE @ZUSArtikelID int = (SELECT ID FROM Artikel WHERE ArtikelNr = N'ZUS');
DECLARE @ZUSBereichID int = (SELECT BereichID FROM Artikel WHERE ArtikelNr = N'ZUS');
DECLARE @BereichID int = (SELECT ID FROM Bereich WHERE Bereich = N'EV');
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE MitarbeiUser = N'THALST');

INSERT INTO @ZUS
SELECT DISTINCT Kunden.ID AS KundenID, KdArti.WaschPreis
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdArti ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
--LEFT OUTER JOIN ZUSKd ON ZUSKd.KundenID = Kunden.ID
WHERE NOT EXISTS (
    SELECT KA.*
    FROM KdArti AS KA
    JOIN Artikel ON KA.ArtikelID = Artikel.ID
    WHERE Artikel.ArtikelNr IN (N'ZUS', N'ZUSDMG')
      AND KA.KundenID = Kunden.ID
  )
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND KdGf.KurzBez != N'INT'
  AND Kunden.KdNr NOT IN (13425, 30198, 30499, 30568, 31225, 31237, 31416)
  AND (UPPER(Artikel.ArtikelBez) LIKE N'%ZUSTELL%' OR UPPER(Artikel.ArtikelBez) LIKE N'%ANFAHR%' OR Artikel.ArtikelNr LIKE N'ZUS%')
  AND KdArti.Status = N'A'
  AND KdArti.WaschPreis != 0
  AND Firma.SuchCode IN (N'FA14', N'WOMI', N'UKLU');

/* SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, KdArti.WaschPreis AS Bearbeitungspreis
FROM (
  SELECT KundenID
  FROM @ZUS AS ZUS
  GROUP BY KundenID
  HAVING COUNT(KundenID) > 1
) AS ZUSKunden
JOIN Kunden ON ZUSKunden.KundenID = Kunden.ID
JOIN KdArti ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE (UPPER(Artikel.ArtikelBez) LIKE N'%ZUSTELL%' OR UPPER(Artikel.ArtikelBez) LIKE N'%ANFAHR%' OR Artikel.ArtikelNr LIKE N'ZUS%')
  AND KdArti.Status = N'A'; */

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Vertrag für mehrere Bereiche gültig machen, falls kein anderer Vertrag für den Bereich EV möglich ist                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* SELECT Vertrag.*
FROM Vertrag
WHERE Vertrag.KundenID IN (SELECT DISTINCT KundenID FROM @ZUS)
  AND Vertrag.Status = N'A'
  AND NOT EXISTS (
    SELECT V.ID
    FROM Vertrag AS V
    WHERE V.BereichID IN (-1, @BereichID)
      AND V.Status = N'A'
      AND V.KundenID = Vertrag.KundenID
  ); */

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kundenbereich EV (Eigenverbrauch) anlegen                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO KdBer ([Status], KundenID, BereichID, VertragID, FakFreqID, ServiceID, VertreterID, BetreuerID, RechKoServiceID, AnfAusEpo, AnlageUserID_, UserID_)
OUTPUT inserted.ID AS KdBerID, inserted.KundenID, inserted.VertragID, inserted.ServiceID, inserted.VertreterID, inserted.BetreuerID
INTO @KdBerInserted
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
WHERE Kunden.ID IN (SELECT DISTINCT KundenID FROM @ZUS)
  AND NOT EXISTS (
    SELECT KdBer.*
    FROM KdBer
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE Bereich.Bereich = N'EV'
      AND KdBer.KundenID = Kunden.ID
  )
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.Status = N'A'
  )
  AND EXISTS (
    SELECT Vertrag.*
    FROM Vertrag
    WHERE Vertrag.KundenID = Kunden.ID
      AND Vertrag.Status = N'A'
  );

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ VSA-Bereiche anlegen bei allen VSAs der Kunden, für die im vorigen Schritt der Kundenbereich angelegt wurde               ++ */
/* ++ TODO: VSA-Bereich auch bei Kunden anlegen, wo der Kundenbereich bereits existierte,                                       ** */
/* ++       aber bei einigen VSAs der Bereich fehlt                                                                             ** */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO VsaBer ([Status], VsaID, KdBerID, VertragID, ServiceID, VertreterID, BetreuerID, AnfAusEpo, VsaTourUnnoetig, ErstFakLeas, ErstLS, AnlageUserID_, UserID_)
SELECT N'A' AS [Status], Vsa.ID AS VsaID, InsertedKdBer.KdBerID, InsertedKdBer.VertragID, InsertedKdBer.ServiceID, InsertedKdBer.VertreterID, InsertedKdBer.BetreuerID, 0 AS AnfAusEPo, 1 AS VsaTourUnnoetig, N'1980/01' AS ErstFakLeas, N'1980/01' AS ErstLs, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM @KdBerInserted AS InsertedKdBer
JOIN Vsa ON InsertedKdBer.KundenID = Vsa.KundenID
WHERE Vsa.[Status] = N'A';

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Artikel ZUS als Kundenartikel anlegen                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, WaschPreis, WebArtikel)
OUTPUT inserted.ID AS KdArtiID, inserted.KundenID, inserted.ArtikelID, inserted.WaschPreis
INTO @ZUSInserted
SELECT N'A' AS [Status], ZUSKunden.KundenID, @ZUSArtikelID AS ArtikelID, KdBer.ID AS KdBerID, ZUSKunden.WaschPreis, CAST(0 AS bit) AS WebArtikel
FROM @ZUS AS ZUSKunden
JOIN KdBer ON KdBer.KundenID = ZUSKunden.KundenID
WHERE KdBer.BereichID = @ZUSBereichID
  AND ZUSKunden.KundenID NOT IN (
    SELECT KundenID
    FROM @ZUS AS ZUS
    GROUP BY KundenID
    HAVING COUNT(KundenID) > 1
  );

SELECT Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, ZUSInserted.WaschPreis AS Bearbeitungspreis
FROM @ZUSInserted AS ZUSInserted
JOIN Kunden ON ZUSInserted.KundenID = Kunden.ID
JOIN Artikel ON ZUSInserted.ArtikelID = Artikel.ID;