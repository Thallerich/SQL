DECLARE @FixMe TABLE (
  BehaltNr int
);

INSERT INTO @FixMe VALUES (339), (309), (313), (327);

/* WITH SetStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'OPEtiKo')
),
BehaltStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'OPBehalt')
)
SELECT OPEtiKo.ID AS OPEtiKoID, SetStatus.StatusBez AS [Status Set], OPBehalt.BehaltNr, BehaltStatus.StatusBez AS [Status Behälter], OPEtiKo.DruckZeitpunkt, OPEtiKo.PackZeitpunkt, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung]
FROM OPBehalt
JOIN OPEtiKo ON OPBehalt.OPEtiKoID = OPEtiKo.ID
JOIN Vsa ON OPEtiKo.PackVsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN SetStatus ON OPEtiKo.[Status] = SetStatus.[Status]
JOIN BehaltStatus ON OPBehalt.[Status] = BehaltStatus.[Status]
WHERE OPBehalt.BehaltNr IN (SELECT f.BehaltNr FROM @FixMe AS f)
  AND OPBehalt.OPEtiKoID > 0; */

UPDATE OPEwVoPo SET OPBehaltID = -1
WHERE OPBehaltID IN (
  SELECT OPBehalt.ID
  FROM OPBehalt
  WHERE OPBehalt.BehaltNr IN (SELECT f.BehaltNr FROM @FixMe AS f)
);

UPDATE OPBehalt SET [Status] = N'E', OPEtiKoID = -1
WHERE BehaltNr IN (SELECT f.BehaltNr FROM @FixMe AS f);

GO