DECLARE @LsNullsetzen TABLE (
  KdNr int,
  Kunde nvarchar(20) COLLATE Latin1_General_CS_AS,
  VsaNr int,
  Vsa nvarchar(40) COLLATE Latin1_General_CS_AS,
  VsaBezeichnung nvarchar(40) COLLATE Latin1_General_CS_AS,
  LsNr int,
  Lieferdatum date,
  LsMitChip int,
  LieferdatumLsMitChip date,
  LsKoID_manuell int,
  LsKoID_CIT int
);

INSERT INTO @LsNullsetzen
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS Vsa, Vsa.Bez AS VsaBezeichnung, LsKo.LsNr, LsKo.Datum AS Lieferdatum, LsChip.LsNr AS LsMitChip, LsChip.Datum LieferdatumLsMitChip, LsKo.ID AS LsKoID_manuell, LsChip.LsKoID AS LsKoID_CIT
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
LEFT OUTER JOIN (
  SELECT DISTINCT LsPo.LsKoID, LKo.LsNr, LKo.Datum, LKo.VsaID
  FROM LsPo
  JOIN LsKo AS LKO ON LsPo.LsKoID = LKo.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
  WHERE LKo.Datum >= N'2019-05-30'
    AND Artikel.BereichID IN (SELECT ID FROM Bereich WHERE Bereich IN (N'SH', N'FW', N'TW'))
    AND ArtGru.Barcodiert = 1
    AND ArtGru.ZwingendBarcodiert = 1
    AND EXISTS (
      SELECT OPScans.*
      FROM OPScans
      JOIN AnfPo ON OPScans.AnfPoID = AnfPo.ID
      JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
      WHERE AnfKo.LsKoID = LKo.ID
        AND AnfPo.KdArtiID = LsPo.KdArtiID
    )
) AS LsChip ON LsChip.VsaID = Vsa.ID AND LsChip.Datum = LsKo.Datum
WHERE EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN LsKo AS LKO ON LsPo.LsKoID = LKo.ID
    JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
    WHERE LsPo.LsKoID = LsKo.ID
      AND LKo.Datum >= N'2019-05-30'
      AND Artikel.BereichID IN (SELECT ID FROM Bereich WHERE Bereich IN (N'SH', N'FW', N'TW'))
      AND ArtGru.Barcodiert = 1
      AND ArtGru.ZwingendBarcodiert = 1
      AND NOT EXISTS (
        SELECT OPScans.*
        FROM OPScans
        JOIN AnfPo ON OPScans.AnfPoID = AnfPo.ID
        JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
        WHERE AnfKo.LsKoID = LKo.ID
          AND AnfPo.KdArtiID = LsPo.KdArtiID
      )
  )
  AND NOT EXISTS (
    SELECT AnfKo.*
    FROM AnfKo
    WHERE AnfKo.LsKoID = LsKo.ID
  )
  AND LsChip.LsNr IS NOT NULL;

SELECT * FROM @LsNullsetzen ORDER BY KdNr, VsaNr, Lieferdatum;

UPDATE LsPo SET Menge = 0, UrMenge = Menge, LsPo.Memo = N'2019-05-31: Lieferschein auf Null gesetzt, da während eines Softwareausfalls am 30.05.2019 ein manueller Lieferschein erstellt wurde. Korrekter Lieferschein: ' + RTRIM(CAST(LSN.LsNr AS char)) + '  -- IT'
FROM LsPo
JOIN @LsNullsetzen AS LSN ON LSN.LsKoID_CIT = LsPo.LsKoID
  AND LsPo.Menge > 0;

UPDATE LsKo SET Memo = N'2019-05-31: Lieferschein auf Null gesetzt, da während eines Softwareausfalls am 30.05.2019 ein manueller Lieferschein erstellt wurde. Korrekter Lieferschein: ' + RTRIM(CAST(LSN.LsNr AS char)) + '  -- IT'
FROM LsKo
JOIN @LsNullsetzen AS LSN ON LSN.LsKoID_CIT = LsKo.ID;