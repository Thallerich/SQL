USE Wozabal;

SELECT FORMAT(CAST(LsCont.Anlage_ AS date), 'd', 'de-AT') AS [Datum Zuweisung], Contain.Barcode AS [Container-Barcode], Artikel.ArtikelBez AS [Container-Art], IIF(LsCont.LsKoID > 0, LsStandKon.Bez, AnfStandKon.Bez) AS Produktion, Mitarbei.UserName AS [AdvanTex-Benutzer], COUNT(LsCont.ID) AS [Anzahl Zuweisungen]
FROM LsCont
JOIN Contain ON LsCont.ContainID = Contain.ID
JOIN Artikel ON Contain.ArtikelID = Artikel.ID
JOIN LsKo ON LsCont.LsKoID = LsKo.ID
JOIN Vsa AS LsVsa ON LsKo.VsaID = LsVsa.ID
JOIN StandKon AS LsStandKon ON LsVsa.StandKonID = LsStandKon.ID
JOIN AnfKo ON LsCont.AnfKoID = AnfKo.ID
JOIN Vsa AS AnfVsa ON AnfKo.VsaID = AnfVsa.ID
JOIN StandKon AS AnfStandKon ON AnfVsa.StandKonID = AnfStandKon.ID
JOIN Mitarbei ON LsCont.AnlageUserID_ = Mitarbei.ID
WHERE LsCont.Anlage_ > N'2018-01-01 00:00:00'
GROUP BY CAST(LsCont.Anlage_ AS date), Contain.Barcode, Artikel.ArtikelBez, IIF(LsCont.LsKoID > 0, LsStandKon.Bez, AnfStandKon.Bez), Mitarbei.UserName
HAVING COUNT(LsCont.ID) > 10
ORDER BY CAST(LsCont.Anlage_ AS date) ASC, [Container-Barcode] ASC;