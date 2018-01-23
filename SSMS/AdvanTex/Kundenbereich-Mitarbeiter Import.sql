-- ## Requieres data to be imported into table [Wozabal_Test].[dbo].[__KundenbetreuerGP]
-- ## Written for Excel file as found in tick.IT:18300

USE Wozabal
GO

IF object_id('tempdb..#TmpKdBerNeu') IS NOT NULL
BEGIN
	DROP TABLE #TmpKdBerNeu;
END
GO

SELECT KGP.KdBerID, KdBer.ID AS KdBerIDW, 
	KGP.KdNr, 
	KGP.Kundenservice, Kundenservice.Name AS KName, 
	IIF(Kundenservice.ID IS NULL, -1, Kundenservice.ID) AS KMitarbeiID, 
	KGP.Vetrieb, 
	Vertrieb.Name AS VName, 
	IIF(Vertrieb.ID IS NULL, -1, Vertrieb.ID) AS VMitarbeiID,
	KGP.Betreuung, 
	Betreuung.Name AS BName,
	IIF(Betreuung.ID IS NULL, -1, Betreuung.ID) AS BMitarbeiID
INTO #TmpKdBerNeu
FROM Wozabal_Test.dbo.__KundenbetreuerGP KGP
JOIN KdBer ON KGP.KdBerID = KdBer.ID
LEFT OUTER JOIN Mitarbei Kundenservice ON KGP.Kundenservice = Kundenservice.Name COLLATE Latin1_GENERAL_CS_AS
LEFT OUTER JOIN Mitarbei Vertrieb ON KGP.Vetrieb = Vertrieb.Name COLLATE Latin1_GENERAL_CS_AS
LEFT OUTER JOIN Mitarbei Betreuung ON KGP.Betreuung = Betreuung.Name COLLATE Latin1_GENERAL_CS_AS
GO

UPDATE KdBer SET KdBer.ServiceID = KdBerNeu.KMitarbeiID, KdBer.VertreterID = KdBerNeu.VMitarbeiID, KdBer.BetreuerID = KdBerNeu.BMitarbeiID
FROM KdBer, #TmpKdBerNeu KdBerNeu
WHERE KdBerNeu.KdBerID = KdBer.ID
	AND (KdBerNeu.KMitarbeiID <> KdBer.ServiceID OR KdBerNeu.VMitarbeiID <> KdBer.VertreterID OR KdBerNeu.BMitarbeiID <> KdBer.BetreuerID);
GO

UPDATE VsaBer SET VsaBer.ServiceID = KdBerNeu.KMitarbeiID, VsaBer.VertreterID = KdBerNeu.VMitarbeiID, VsaBer.BetreuerID = KdBerNeu.BMitarbeiID
FROM VsaBer, #TmpKdBerNeu KdBerNeu
WHERE KdBerNeu.KdBerID = VsaBer.KdBerID
	AND (KdBerNeu.KMitarbeiID <> VsaBer.ServiceID OR KdBerNeu.VMitarbeiID <> VsaBer.VertreterID OR KdBerNeu.BMitarbeiID <> VsaBer.BetreuerID);
GO