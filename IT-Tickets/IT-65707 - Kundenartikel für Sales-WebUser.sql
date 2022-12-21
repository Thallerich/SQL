/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ KdBer                                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO KdBer ([Status], KundenID, BereichID, VertragID, FakFreqID, ServiceID, VertreterID, BetreuerID, RechKoServiceID, AnfAusEpo, AnlageUserID_, UserID_)
SELECT N'A' AS [Status], Kunden.ID AS KundenID, Bereich.ID AS BereichID, VertragID = (
    SELECT TOP 1 Vertrag.ID
    FROM Vertrag
    WHERE Vertrag.BereichID = -1
      AND Vertrag.Status = N'A'
      AND Vertrag.KundenID = Kunden.ID
    ORDER BY Vertrag.Anlage_ DESC
  ),
  FakFreqID = 43,
  ServiceID = ISNULL((
    SELECT TOP 1 KdBer.ServiceID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.ServiceID
    ORDER BY COUNT(KdBer.ID)
  ), -1),
  VertreterID = ISNULL((
    SELECT TOP 1 KdBer.VertreterID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.VertreterID
    ORDER BY COUNT(KdBer.ID)    
  ), -1),
  BetreuerID = ISNULL((
    SELECT TOP 1 KdBer.BetreuerID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.BetreuerID
    ORDER BY COUNT(KdBer.ID)
  ), -1),
  RechKoServiceID = ISNULL((
    SELECT TOP 1 KdBer.RechKoServiceID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.RechKoServiceID
    ORDER BY COUNT(KdBer.ID)
  ), -1),
  0 AS AnfAusEPo, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM Kunden
CROSS JOIN (
  SELECT DISTINCT Bereich.ID
  FROM Artikel
  JOIN Bereich ON Artikel.BereichID = Bereich.ID
  WHERE Artikel.ArtikelNr IN (SELECT ArtikelNr FROM Salesianer.dbo._IT65707Artikel)
) Bereich
WHERE Kunden.KdNr IN (SELECT KdNr FROM Salesianer.dbo._IT65707WebUser)
  AND Kunden.Status = N'A'
  AND NOT EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.BereichID = Bereich.ID
      AND KdBer.KundenID = Kunden.ID
  );

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ KdArti                                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

MERGE INTO KdArti USING (
  SELECT Artikel.ID AS ArtikelID, Kunden.ID AS KundenID, KdBer.ID AS KdBerID, Artikel.WaschPrgID, Artikel.MaxWaschen
  FROM Artikel
  CROSS JOIN Salesianer.dbo._IT65707WebUser
  JOIN Kunden ON Salesianer.dbo._IT65707WebUser.KdNr = Kunden.KdNr
  JOIN Salesianer.dbo._IT65707Artikel ON _IT65707Artikel.ArtikelNr = Artikel.ArtikelNr
  JOIN KdBer ON KdBer.KundenID = Kunden.ID AND KdBer.BereichID = Artikel.BereichID
) AS KdArtiSales (ArtikelID, KundenID, KdBerID, WaschPrgID, MaxWaschen)
ON KdArti.KundenID = KdArtiSales.KundenID AND KdArti.ArtikelID = KdArtiSales.ArtikelID
WHEN MATCHED THEN
  UPDATE SET [Status] = N'A', WebArtikel = 1, UserID_ = @UserID
WHEN NOT MATCHED THEN
  INSERT (KundenID, ArtikelID, KdBerID, WaschPrgID, MaxWaschen, WebArtikel, AnlageUserID_, UserID_)
  VALUES (KdArtiSales.KundenID, KdArtiSales.ArtikelID, KdArtiSales.KdBerID, KdArtiSales.WaschPrgID, KdArtiSales.MaxWaschen, CAST(1 AS bit), @UserID, @UserID);

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ VsaArti leeren                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DELETE
FROM VsaArti
WHERE ID IN (
  SELECT VsaArti.ID
  FROM VsaArti
  JOIN Vsa ON VsaArti.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Kunden.KdNr IN (SELECT KdNr FROM Salesianer.dbo._IT65707WebUser)
);

GO