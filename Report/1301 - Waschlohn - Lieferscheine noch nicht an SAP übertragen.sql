SELECT Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, LsKo.Datum AS Lieferdatum, LsKo.LsNr, LsKo.InternKalkFix AS [Waschlohn fixiert?], LsKo.SentToSAP AS [an SAP gesendet?], LsKo.ID AS LsKoID, LsKo.Anlage_, Mitarbei.Name AS AnlageUser_
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Mitarbei ON LsKo.AnlageUserID_ = Mitarbei.ID
WHERE LsKo.Status >= N'Q'
  AND ((Firma.SuchCode = N'FA14' AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU')) OR (Firma.SuchCode != N'FA14'))
  AND Kunden.FirmaID IN ($2$)
  AND LsKo.SentToSAP = 0
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.Menge != 0
      AND LsPo.EPreis != 0
  )
ORDER BY Firma, KdNr, Lieferdatum;