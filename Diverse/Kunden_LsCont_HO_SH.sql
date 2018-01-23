SELECT TRIM(Vsa.Name1) AS 'VSA Name1', TRIM(IIF(Vsa.Name2 IS NULL,'',Vsa.Name2)) AS 'VSA Name2', Vsa.PLZ, Vsa.Ort
FROM Kunden, Vsa, KdGf
WHERE Vsa.KundenID = Kunden.ID
AND Kunden.KdGfID = KdGf.ID
AND KdGf.KurzBez IN ('HO', 'SH')
AND Kunden.Status <> 'I'