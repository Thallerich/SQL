SELECT LsKo.Datum AS Lieferdatum, StandKon.StandKonBez AS [Standort-Konfiguration], Artikel.ArtikelBez + ' (' + Artikel.ArtikelNr + ')' AS Containertyp, COUNT(DISTINCT LsCont.ContainID) AS [Anzahl Container]
FROM LsCont
JOIN LsKo ON LsCont.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN Contain ON LsCont.ContainID = Contain.ID
JOIN Artikel ON Contain.ArtikelID = Artikel.ID
WHERE LsKo.Datum = CAST(GETDATE() AS date)
GROUP BY LsKo.Datum, StandKon.StandKonBez, Artikel.ArtikelBez + ' (' + Artikel.ArtikelNr + ')';