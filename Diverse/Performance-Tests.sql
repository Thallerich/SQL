SELECT LsKo.ID, LsKo.Datum, COUNT(LsPo.ID)
FROM LsKo
LEFT JOIN LsPo ON LsPo.LsKoID = LsKo.ID
GROUP BY LsKo.ID, LsKo.Datum
HAVING COUNT(LsPo.ID) = 0
ORDER BY Datum DESC

------- 17.12.2010: 110 - 120 Sekunden ---------