DECLARE @timestamp datetime2 = DATEADD(minute, -20, GETDATE());

SELECT DENSE_RANK() OVER (ORDER BY EinzTeil.ID) AS ItemNo, EinzTeil.Code, Artikel.ArtikelNr, Artikel.ArtikelBez, EinzTeil.ArtGroeID, ArtGroe.Groesse, Scans.[DateTime], Scans.ZielNrID, ZielNr.ZielNrBez, ArbPlatz.ComputerName, Mitarbei.MitarbeiUser, Scans.VPSPoID, VpsPo.Anlage_
FROM EinzTeil
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
LEFT JOIN (SELECT Scans.* FROM Scans WHERE Scans.[DateTime] > @timestamp) Scans ON EinzTeil.ID = Scans.EinzTeilID
LEFT JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
LEFT JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
LEFT JOIN Mitarbei ON ArbPlatz.LastMitarbeiID = Mitarbei.ID
LEFT JOIN VpsPo ON Scans.VPSPoID = VpsPo.ID
WHERE EinzTeil.Code IN ('3034438200455884000026D0', '300ED89F3350009333538BFA', '3034438200445E840000BA9D', '300ED89F3350015A1E3F1ABF', '30344382004558840000485E', '300ED89F335001501DCF9DCA')
ORDER BY ItemNo, [DateTime] ASC

GO