DROP TABLE IF EXISTS #AnfForEnns;

GO

DECLARE @KdNr int = 202899;
DECLARE @DateFrom date = N'2023-06-26';

SELECT AnfKo.ID, AnfKo.AuftragsNr, AnfKo.[Status]
INTO #AnfForEnns
FROM AnfKo
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = @KdNr
  AND Vsa.StandKonID IN (SELECT ID FROM StandKon WHERE StandKonBez LIKE N'Produktion GP Enns%')
  AND AnfKo.LieferDatum >= @DateFrom
  AND AnfKo.Status <= N'I'
  AND AnfKo.PZArtID != (SELECT ID FROM PzArt WHERE Kuerzel = N'CITUHF');

GO

UPDATE AnfKo SET PZArtID = (SELECT ID FROM PzArt WHERE Kuerzel = N'CITUHF')
WHERE ID IN (
  SELECT ID
  FROM #AnfForEnns
);

GO

INSERT INTO AnfExpQ (Typ, AnfKoID, BearbSys, AuftragsNr)
SELECT N'U', #AnfForEnns.ID, 2, #AnfForEnns.AuftragsNr
FROM #AnfForEnns
WHERE #AnfForEnns.[Status] = N'I';

GO