/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Get Data                                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Result999146;

CREATE TABLE #Result999146 (
  StandortID int NOT NULL,
  KundenID int NOT NULL,
  VsaID int DEFAULT NULL,
  BewohnerAnz int NOT NULL
);

CREATE TABLE #Haupstandort (
  StandortID int PRIMARY KEY CLUSTERED
);

INSERT INTO #Haupstandort (StandortID)
SELECT Standort.ID
FROM Standort
WHERE Standort.ID IN ($1$);

DECLARE @sqltext nvarchar(max);

IF $2$ = 0
  SET @sqltext = N'
    SELECT Kunden.StandortID, Kunden.ID AS KundenID, NULL AS VsaID, COUNT(Traeger.ID) AS [Anzahl Bewohner]
    FROM Traeger
    JOIN Vsa ON Traeger.VsaID = Vsa.ID
    JOIN Kunden ON Vsa.KundenID = Kunden.ID
    WHERE Kunden.StandortID IN (SELECT StandortID FROM #Haupstandort)
      AND Kunden.[Status] = N''A''
      AND Vsa.[Status] = N''A''
      AND Traeger.[Status] != N''I''
      AND Traeger.Altenheim = 1
    GROUP BY Kunden.StandortID, Kunden.ID;
  ';
ELSE
  SET @sqltext = N'
    SELECT Kunden.StandortID, Kunden.ID AS KundenID, Vsa.ID AS VsaID, COUNT(Traeger.ID) AS [Anzahl Bewohner]
    FROM Traeger
    JOIN Vsa ON Traeger.VsaID = Vsa.ID
    JOIN Kunden ON Vsa.KundenID = Kunden.ID
    WHERE Kunden.StandortID IN (SELECT StandortID FROM #Haupstandort)
      AND Kunden.[Status] = N''A''
      AND Vsa.[Status] = N''A''
      AND Traeger.[Status] != N''I''
      AND Traeger.Altenheim = 1
    GROUP BY Kunden.StandortID, Kunden.ID, Vsa.ID;
  ';

INSERT INTO #Result999146 (StandortID, KundenID, VsaID, BewohnerAnz)
EXEC sp_executesql @sqltext;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Report                                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Standort.Bez AS [Haupstandort Kunde], Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], #Result999146.BewohnerAnz AS [Anzahl Bewohner]
FROM #Result999146
LEFT JOIN Vsa ON #Result999146.VsaID = Vsa.ID
JOIN Kunden ON #Result999146.KundenID = Kunden.ID
JOIN Standort ON #Result999146.StandortID = Standort.ID;