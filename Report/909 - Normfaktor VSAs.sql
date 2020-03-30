SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Vsa.NormFaktor1 AS [Normfaktor Montag], Vsa.NormFaktor2 AS [Normfaktor Dienstag], Vsa.NormFaktor3 AS [Normfaktor Mittwoch], Vsa.NormFaktor4 AS [Normfaktor Donnerstag], Vsa.NormFaktor5 AS [Normfaktor Freitag], Vsa.NormFaktor6 AS [Normfaktor Samstag], Vsa.NormFaktor7 AS [Normfaktor Sonntag]
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Vsa.StandKonID IN ($1$)
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND (
       Vsa.Normfaktor1 != 0
    OR Vsa.NormFaktor2 != 0
    OR Vsa.NormFaktor3 != 0
    OR Vsa.NormFaktor4 != 0
    OR Vsa.NormFaktor5 != 0
    OR Vsa.NormFaktor6 != 0
    OR Vsa.NormFaktor7 != 0
  )
  AND EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.VsaID = Vsa.ID
      AND VsaAnf.Art IN (N'N', N'X')
  );