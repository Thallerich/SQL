DECLARE @WorkTable TABLE (
  PzNr nchar(20) COLLATE Latin1_General_CS_AS,
  LsNr int,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  OwnerKdNr int
);

DECLARE @RemoveOwner TABLE (
  OPTeileID int
);

INSERT INTO @WorkTable VALUES
  ('21348703', 43462597, '41001983509', 100151),
  ('21348703', 43462597, '41001983510', 100151),
  ('21348703', 43462597, '41001983511', 100151),
  ('21348703', 43462597, 'P4WA', 100151),
  ('21348703', 43462597, 'P7WTL', 100151),
  ('21348703', 43462597, 'P7WTM', 100151),
  ('21348703', 43462597, 'P7WTS', 100151);

INSERT INTO @RemoveOwner 
SELECT OPTeile.ID
FROM OPScans
JOIN OPTeile ON OPScans.OPTeileID = OPTeile.ID
JOIN AnfPo ON OPScans.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Vsa AS OwnerVsa ON OPTeile.VsaOwnerID = OwnerVsa.ID
JOIN Kunden AS OwnerKunde ON OwnerVsa.KundenID = OwnerKunde.ID
JOIN @WorkTable AS WorkTable ON Artikel.ArtikelNr = WorkTable.ArtikelNr AND AnfKo.AuftragsNr = WorkTable.PzNr AND OwnerKunde.KdNr = WorkTable.OwnerKdNr;

UPDATE OPTeile SET VsaOwnerID = -1
WHERE ID IN (
  SELECT OPTeileID
  FROM @RemoveOwner
);