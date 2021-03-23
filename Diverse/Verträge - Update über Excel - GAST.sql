-- UPDATE __TestVertragsupdate SET KdNr = CAST(RIGHT(CAST(KdNr AS nchar(7)), 5) AS int);

UPDATE Vertrag SET Vertrag.VertragStart = __TestVertragsupdate.VertragAb, Vertrag.VertragEnde = __TestVertragsupdate.VertragAb2, Vertrag.VertragFristErst = ISNULL(__TestVertragsupdate.KuendFristErst, 0), Vertrag.VertragFrist = ISNULL(__TestVertragsupdate.KuendFristFolge, 0), Vertrag.VertragVerlaeng = ISNULL(__TestVertragsupdate.autoVerlaengerung, 0)
FROM Vertrag
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN __TestVertragsupdate ON Kunden.KdNr = __TestVertragsupdate.KdNr
WHERE Vertrag.Status = N'A';