/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Mit Mail ohne Empfänger                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Standort.SuchCode AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, RKoAnlag.RkoAnlagBez$LAN$ AS Rechnungsanlage, CAST(IIF(KdRKoAnl.Drucken = 1 AND (RKoOut.Papierdruck = 1 OR RKoOut.VersandPath IS NOT NULL), 1, 0) AS bit) AS [wird auch gedruckt?]
FROM KdRKoAnl
JOIN RKoAnlag ON KdRKoAnl.RKoAnlagID = RKoAnlag.ID
JOIN Kunden ON KdRKoAnl.KundenID = Kunden.ID
JOIN RKoOut ON Kunden.RKoOutID = RKoOut.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE (KdRKoAnl.PDF = 1 OR KdRKoAnl.CSV = 1)
  AND NOT EXISTS (
    SELECT RKoMail.*
    FROM RKoMail
    WHERE RKoMail.TableID = Kunden.ID
      AND RKoMail.TableName = N'KUNDEN'
      AND RKoMail.FieldName = N'ANLAGEMAIL'
  )
  AND NOT EXISTS (
    SELECT RKoMail.*
    FROM RKoMail
    WHERE RKoMail.TableID = KdRKoAnl.ID
      AND RKoMail.TableName = N'KDRKOANL'
      AND RKoMail.FieldName = N'ANLAGEMAIL'
  )
  AND Kunden.FirmaID = $1$
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND (($2$ = 0) OR ($2$ = 1 AND (KdRKoAnl.Drucken = 0 OR (KdRKoAnl.Drucken = 1 AND RKoOut.Papierdruck = 0 AND RKoOut.VersandPath IS NULL))));

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Ohne Mail mit Empfänger                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Standort.SuchCode AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, RKoAnlag.RkoAnlagBez$LAN$ AS Rechnungsanlage, CAST(IIF(KdRKoAnl.Drucken = 1 AND (RKoOut.Papierdruck = 1 OR RKoOut.VersandPath IS NOT NULL), 1, 0) AS bit) AS [wird auch gedruckt?]
FROM KdRKoAnl
JOIN RKoAnlag ON KdRKoAnl.RKoAnlagID = RKoAnlag.ID
JOIN Kunden ON KdRKoAnl.KundenID = Kunden.ID
JOIN RKoOut ON Kunden.RKoOutID = RKoOut.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE (
  EXISTS (
    SELECT RKoMail.*
    FROM RKoMail
    WHERE RKoMail.TableID = Kunden.ID
      AND RKoMail.TableName = N'KUNDEN'
      AND RKoMail.FieldName = N'ANLAGEMAIL'
    )
    OR EXISTS (
      SELECT RKoMail.*
      FROM RKoMail
      WHERE RKoMail.TableID = KdRKoAnl.ID
        AND RKoMail.TableName = N'KDRKOANL'
        AND RKoMail.FieldName = N'ANLAGEMAIL'
    )
  )
  AND KdRKoAnl.PDF = 0
  AND KdRKoAnl.CSV = 0
  AND Kunden.FirmaID = $1$
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND (($2$ = 0) OR ($2$ = 1 AND (KdRKoAnl.Drucken = 0 OR (KdRKoAnl.Drucken = 1 AND RKoOut.Papierdruck = 0 AND RKoOut.VersandPath IS NULL))));