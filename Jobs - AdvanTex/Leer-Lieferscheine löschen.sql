DECLARE @LeerLS TABLE (
  LsKoID int
);

INSERT INTO @LeerLS
SELECT LsKo.ID
FROM Kunden, Vsa, LsKo
LEFT OUTER JOIN LsPo ON LsPo.LsKoID = LsKo.ID
WHERE LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND ((LsKo.Datum >= GETDATE() AND Kunden.FirmaID = 5001) OR (LsKo.Datum < GETDATE() - 7 AND LsKo.Datum >= GETDATE() - 30))
  AND NOT EXISTS (
    SELECT ContHist.*
    FROM ContHist
    WHERE ContHist.LsKoID = LsKo.ID
  )
  AND NOT EXISTS (
    SELECT LsCont.*
    FROM LsCont
    WHERE LsCont.LsKoID = LsKo.ID
  )
  AND NOT EXISTS (
    SELECT AnfKo.*
    FROM AnfKo
    WHERE AnfKo.LsKoID = LsKo.ID
  )
  AND NOT EXISTS (
    SELECT SammelLs.*
    FROM LsKo AS SammelLs
    WHERE SammelLs.SammelLsKoID = LsKo.ID
  )
GROUP BY LsKo.ID, LsKo.LsNr, LsKo.Datum
HAVING COUNT(LsPo.ID) = 0;

DELETE FROM LsKo
WHERE ID IN (SELECT LsKoID FROM @LeerLS);