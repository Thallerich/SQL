SELECT SUM(PosSum)
FROM (
  SELECT AbtKdArW.RechPoID, ROUND(SUM(AbtKdArW.Menge * AbtKdArW.EPreis), 2) PosSum
  FROM AbtKdArW
  WHERE AbtKdArW.RechPoID IN (SELECT RechPo.ID FROM RechPo WHERE RechPo.RechKoID = (SELECT RechKo.ID FROM RechKo WHERE RechKo.RechNr = 30355381))
  GROUP BY AbtKdArW.RechPoID
) x;

GO

SELECT SUM(RechPo.GPreis)
FROM RechPo
WHERE RechPo.RechKoID = (SELECT RechKo.ID FROM RechKo WHERE RechKo.RechNr = 30355381)
  AND RechPo.RPoTypeID = 1;

GO

SELECT COUNT(DISTINCT CAST(Wochen.ID AS nvarchar) + N'/' + CAST(EinzHist.ID AS nvarchar))
FROM TraeArch
JOIN Wochen ON TraeArch.WochenID = Wochen.ID
JOIN [Week] ON Wochen.Woche = [Week].Woche
JOIN EinzHist ON TraeArch.TraeArtiID = EinzHist.TraeArtiID AND EinzHist.Indienst IS NOT NULL AND Wochen.Woche >= EinzHist.Indienst AND Wochen.Woche < ISNULL(EinzHist.Ausdienst, N'2099/52') AND Week.BisDat BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis AND EinzHist.EinzHistTyp = 1
WHERE TraeArch.AbtKdArWID IN (
  SELECT AbtKdArW.ID
  FROM AbtKdArW
  WHERE AbtKdArW.RechPoID IN (SELECT RechPo.ID FROM RechPo WHERE RechPo.RechKoID = (SELECT RechKo.ID FROM RechKo WHERE RechKo.RechNr = 30355381))
);

GO

SELECT SUM(TraeArch.Menge)
FROM TraeArch
WHERE TraeArch.AbtKdArWID IN (
  SELECT AbtKdArW.ID
  FROM AbtKdArW
  WHERE AbtKdArW.RechPoID IN (SELECT RechPo.ID FROM RechPo WHERE RechPo.RechKoID = (SELECT RechKo.ID FROM RechKo WHERE RechKo.RechNr = 30355381))
);

GO

SELECT TraeArchID, Menge, CountedTeile
FROM (
  SELECT TraeArch.ID AS TraeArchID, TraeArch.Menge, COUNT(DISTINCT CAST(Wochen.ID AS nvarchar) + N'/' + CAST(EinzHist.ID AS nvarchar)) AS CountedTeile
  FROM TraeArch
  JOIN Wochen ON TraeArch.WochenID = Wochen.ID
  JOIN [Week] ON Wochen.Woche = [Week].Woche
  JOIN EinzHist ON TraeArch.TraeArtiID = EinzHist.TraeArtiID AND EinzHist.Indienst IS NOT NULL AND Wochen.Woche >= EinzHist.Indienst AND Wochen.Woche < ISNULL(EinzHist.Ausdienst, N'2099/52') AND Week.BisDat BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis AND EinzHist.EinzHistTyp = 1
  WHERE TraeArch.AbtKdArWID IN (
    SELECT AbtKdArW.ID
    FROM AbtKdArW
    WHERE AbtKdArW.RechPoID IN (SELECT RechPo.ID FROM RechPo WHERE RechPo.RechKoID = (SELECT RechKo.ID FROM RechKo WHERE RechKo.RechNr = 30355381))
  )
  GROUP BY TraeArch.ID, TraeArch.Menge
) x
WHERE x.CountedTeile != x.Menge;

GO

SELECT TraeArch.Menge, Wochen.Woche, Week.VonDat, Week.BisDat, EinzHist.ID AS EinzHistID, EinzHist.TraeArtiID, EinzHist.Barcode, EinzHist.EinzHistTyp, EinzHist.Archiv, EinzHist.[Status], EinzHist.EinzHistVon, EinzHist.EinzHistBis, EinzHist.Indienst, EinzHist.IndienstDat, EinzHist.Ausdienst, EinzHist.AusdienstDat, EinzHist.Abmeldung, EinzHist.AbmeldDat
FROM TraeArch
JOIN Wochen ON TraeArch.WochenID = Wochen.ID
JOIN [Week] ON Wochen.Woche = [Week].Woche
JOIN EinzHist ON TraeArch.TraeArtiID = EinzHist.TraeArtiID AND EinzHist.Indienst IS NOT NULL AND Wochen.Woche >= EinzHist.Indienst AND Wochen.Woche < ISNULL(EinzHist.Ausdienst, N'2099/52') AND Week.BisDat BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis AND EinzHist.EinzHistTyp = 1
WHERE TraeArch.AbtKdArWID IN (
  SELECT AbtKdArW.ID
  FROM AbtKdArW
  WHERE AbtKdArW.RechPoID IN (SELECT RechPo.ID FROM RechPo WHERE RechPo.RechKoID = (SELECT RechKo.ID FROM RechKo WHERE RechKo.RechNr = 30355381))
)
AND TraeArch.ID = 302442335;

GO

SELECT EinzHist.ID AS EinzHistID, EinzHist.TraeArtiID, EinzHist.Barcode, EinzHist.EinzHistTyp, EinzHist.Archiv, EinzHist.[Status], EinzHist.EinzHistVon, EinzHist.EinzHistBis, EinzHist.Indienst, EinzHist.IndienstDat, EinzHist.Ausdienst, EinzHist.AusdienstDat, EinzHist.Abmeldung, EinzHist.AbmeldDat, EinzHist.StornoDateTime
FROM EinzHist
WHERE EinzHist.TraeArtiID = 31038523;

GO