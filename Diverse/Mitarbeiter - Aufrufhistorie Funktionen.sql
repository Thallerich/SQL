DECLARE @User nvarchar(24) = N'EN-GP-LIEFERSCHEINE01';

SELECT Mitarbei.UserName, Mitarbei.Name, FormAct.FormClass, FormAct.ActionName, ModlHist.Aufrufe, ModlHist.LastAufruf, ModlHist.ActionComponent
FROM ModlHist
JOIN FormAct ON ModlHist.FormActID = FormAct.ID
JOIN Mitarbei ON ModlHist.MitarbeiID = Mitarbei.ID
WHERE Mitarbei.MitarbeiUser = @User
ORDER BY LastAufruf DESC;