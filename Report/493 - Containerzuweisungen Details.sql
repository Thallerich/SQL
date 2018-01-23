SELECT Zuweisungsbenutzer, Zuweisung, Container, KdNr, Kunden.SuchCode AS Kunde, Vsa.Bez AS Vsa, AuftragsNr, LsNr, LieferDatum
FROM Vsa, Kunden, (
  SELECT Mitarbei.UserName AS Zuweisungsbenutzer, LsCont.Anlage_ AS Zuweisung, Contain.Barcode AS Container, AnfKo.AuftragsNr, IIF(AnfKo.ID > 0, LS.LsNr, LsKo.LsNr) AS LsNr, IIF(AnfKo.ID > 0, AnfKo.LieferDatum, LsKo.Datum) AS Lieferdatum, IIF(AnfKo.ID > 0, AnfKo.VsaID, LsKo.VsaID) AS VsaID
  FROM LsKo AS LS, Contain, Mitarbei, LsCont 
  LEFT JOIN AnfKo ON LsCont.AnfKoID = AnfKo.ID
  LEFT JOIN LsKo ON LsCont.LsKoID = LsKo.ID
  WHERE ContainID = Contain.ID 
    AND AnfKo.LsKoID = LS.ID 
    AND LsCont.AnlageUserID_ = Mitarbei.ID
    AND CONVERT(date, LsCont.Anlage_) = $1$
) a
WHERE a.VsaID=Vsa.ID 
  AND KundenID=Kunden.ID
ORDER BY Zuweisungsbenutzer, Zuweisung, KdNr;