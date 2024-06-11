SELECT *
FROM (
  SELECT Vsa.ID AS VsaID,
    Vsa.Bez AS VsaBezeichnung,
    LsNr = STUFF((
      SELECT N', ' + CAST(LsKo.LsNr AS nvarchar)
      FROM LsKo
      WHERE LsKo.VsaID = Vsa.ID
        AND EXISTS (
          SELECT LsPo.*
          FROM LsPo
          JOIN RechPo ON LsPo.RechPoID = RechPo.ID
          WHERE LsPo.LsKoID = LsKo.ID
            AND RechPo.RechKoID = $RECHKOID$
        )
      ORDER BY LsNr
      FOR XML PATH('')
    ), 1, 2, N'')
  FROM Vsa
  WHERE Vsa.KundenID = $KUNDENID$
) x
WHERE x.LsNr IS NOT NULL
ORDER BY VsaID;