DROP TABLE IF EXISTS #TmpVOESTRechnung;

DECLARE @RechKo TABLE (
  RechKoID int
);

INSERT INTO @RechKo (RechKoID)
SELECT RechKo.ID
FROM RechKo
WHERE RechKo.RechDat >= DATEADD(MONTH, -11, GETDATE())
  AND RechKo.KundenID IN (
    SELECT Kunden.ID
    FROM Kunden
    JOIN Holding ON Kunden.HoldingID = Holding.ID
    WHERE Holding.Holding IN (N'VOES', N'VOESAN',N'VOESLE')
  );

WITH VOESTProduktbereich AS (
  SELECT Bereich.ID AS BereichID,
    Bereichsbezeichnung = 
      CASE Bereich.Bereich
        WHEN N'BK' THEN N'Arbeitskleidung'
        WHEN N'BC' THEN N'Waschraumhygiene'
        WHEN N'FW' THEN N'Geschirr-, Handtücher, etc.'
        WHEN N'HW' THEN N'Kaufware'
        ELSE Bereich.BereichBez
      END
  FROM Bereich
)
SELECT RechKo.RechNr, RechKo.RechDat, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, VOESTProduktbereich.Bereichsbezeichnung, Art = 
  CASE RPoType.StatistikGruppe
    WHEN N'Bearbeitung' THEN N'Waschpreis'
    WHEN N'Leasing' THEN N'Mietpreis'
    WHEN N'Handelsware' THEN N'Verkauf'
    WHEN N'Restwerte' THEN N'Schrott / Austausch'
    ELSE RPoType.StatistikGruppe
  END,
  SUM(RechPo.GPreis) AS Summe
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN VOESTProduktbereich ON RechPo.BereichID = VOESTProduktbereich.BereichID
JOIN RPoType ON RechPo.RPoTypeID = RPoType.ID
WHERE RechKo.ID IN (SELECT RechKoID FROM @RechKo)
GROUP BY RechKo.RechNr, RechKo.RechDat, Abteil.Abteilung, Abteil.Bez, VOESTProduktbereich.Bereichsbezeichnung, RPoType.StatistikGruppe;