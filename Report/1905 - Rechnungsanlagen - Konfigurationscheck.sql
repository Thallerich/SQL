/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Mit Mail ohne Empfänger                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, RKoAnlag.RkoAnlagBez$LAN$ AS Rechnungsanlage, KdRKoAnl.Drucken AS [wird auch gedruckt?]
FROM KdRKoAnl
JOIN RKoAnlag ON KdRKoAnl.RKoAnlagID = RKoAnlag.ID
JOIN Kunden ON KdRKoAnl.KundenID = Kunden.ID
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
  AND (($2$ = 0) OR ($2$ = 1 AND KdRKoAnl.Drucken = 0));

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Ohne Mail mit Empfänger                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, RKoAnlag.RkoAnlagBez$LAN$ AS Rechnungsanlage, KdRKoAnl.Drucken AS [wird gedruckt?]
FROM KdRKoAnl
JOIN RKoAnlag ON KdRKoAnl.RKoAnlagID = RKoAnlag.ID
JOIN Kunden ON KdRKoAnl.KundenID = Kunden.ID
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
  AND (($2$ = 0) OR ($2$ = 1 AND KdRKoAnl.Drucken = 0));