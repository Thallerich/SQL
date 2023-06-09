DROP TABLE IF EXISTS #AnfPoKorr;

GO

CREATE TABLE #AnfPoKorr (
  AnfPoID int PRIMARY KEY CLUSTERED,
  ArtGroeID int NOT NULL
);

GO

INSERT INTO #AnfPoKorr (AnfPoID, ArtGroeID)
SELECT AnfPo.ID AS AnfPoID, VsaAnf.ArtGroeID
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN VsaAnf ON VsaAnf.KdArtiID = AnfPo.KdArtiID AND VsaAnf.VsaID = AnfKo.VsaID
WHERE Kunden.KdNr = 20125
  AND AnfKo.[Status] <= N'I'
  AND AnfKo.LieferDatum >= CAST(GETDATE() AS date)
  AND AnfPo.ArtGroeID < 0
  AND VsaAnf.ArtGroeID > 0
  AND NOT EXISTS (
    SELECT a.*
    FROM AnfPo a
    WHERE a.AnfKoID = AnfPo.AnfKoID
      AND a.KdArtiID = AnfPo.KdArtiID
      AND a.ArtGroeID = VsaAnf.ArtGroeID
  );

GO

UPDATE AnfPo SET ArtGroeID = #AnfPoKorr.ArtGroeID
FROM #AnfPoKorr
WHERE #AnfPoKorr.AnfPoID = AnfPo.ID;

GO