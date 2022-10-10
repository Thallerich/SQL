DECLARE @LsMap TABLE (
  LsNr int PRIMARY KEY NOT NULL,
  LsKoID int NOT NULL DEFAULT -1,
  KdNr int NOT NULL,
  VsaNr int NOT NULL,
  VsaID int NOT NULL DEFAULT -1,
  Kostenstelle nvarchar(20) COLLATE Latin1_General_CS_AS NOT NULL,
  AbteilID int NOT NULL DEFAULT -1
);

INSERT INTO @LsMap (LsNr, KdNr, VsaNr, Kostenstelle)
VALUES
  (45736768, 2521057, 28, N'2521057/010_2'),
  (45611368, 2521057, 25, N'2521057/006_2'),
  (45611367, 2521057, 24, N'2521057/005_2'),
  (45736767, 2521057, 26, N'2521057/007_2'),
  (45736766, 2521057, 21, N'2521057/001_2');

UPDATE LsMap SET VsaID = Vsa.ID
FROM @LsMap AS LsMap
JOIN Vsa ON LsMap.VsaNr = Vsa.VsaNr
JOIN Kunden ON Vsa.KundenID = Kunden.ID AND LsMap.KdNr = Kunden.KdNr;

UPDATE LsMap SET AbteilID = Abteil.ID
FROM @LsMap AS LsMap
JOIN Abteil ON LsMap.Kostenstelle = Abteil.Abteilung
JOIN Kunden ON Abteil.KundenID = Kunden.ID AND LsMap.KdNr = Kunden.KdNr;

UPDATE LsMap SET LsKoID = LsKo.ID
FROM @LsMap AS LsMap
JOIN LsKo ON LsMap.LsNr = LsKo.LsNr;

BEGIN TRANSACTION;

  UPDATE LsKo SET VsaID = LsMap.VsaID
  FROM @LsMap AS LsMap
  WHERE LsMap.LsKoID = LsKo.ID;

  UPDATE LsPo SET AbteilID = LsMap.AbteilID
  FROM @LsMap AS LsMap
  WHERE LsMap.LsKoID = LsPo.LsKoID;

COMMIT;

GO