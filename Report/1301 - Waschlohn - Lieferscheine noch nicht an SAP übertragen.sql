SELECT Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, LsKo.Datum AS Lieferdatum, LsKo.LsNr, LsKo.InternKalkFix AS [Waschlohn fixiert?], LsKo.SentToSAP AS [an SAP gesendet?]
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE LsKo.Status >= N'Q'
  AND KdGf.KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU')
  AND Kunden.FirmaID IN ($2$)
  AND LsKo.SentToSAP = 0
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
ORDER BY Firma, KdNr, Lieferdatum;