DROP TABLE IF EXISTS #InvResult;

CREATE TABLE #InvResult (
  Lagerstandort nchar(15) COLLATE Latin1_General_CS_AS,
  Lagerart nvarchar(60) COLLATE Latin1_General_CS_AS,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  Größe nchar(12) COLLATE Latin1_General_CS_AS,
  [Zeitpunkt Inventurbuchung] datetime2,
  [Bestand vor Inventur] int DEFAULT 0,
  [Bestand nach Inventur] int DEFAULT 0,
  Differenz int,
  BestandID int,
  GroeKoID int
);

INSERT INTO #InvResult (Lagerstandort, Lagerart, ArtikelNr, Artikelbezeichnung, Größe, [Zeitpunkt Inventurbuchung], Differenz, BestandID, GroeKoID)
SELECT Standort.SuchCode AS Lagerstandort, Lagerart.LagerartBez$LAN$ AS Lagerart, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, MAX(LagerBew.Zeitpunkt) AS [Zeitpunkt Inventurbuchung], SUM(LagerBew.Differenz) AS Differenz, Bestand.ID AS BestandID, Artikel.GroeKoID
FROM LagerBew
JOIN Bestand ON LagerBew.BestandID = Bestand.ID
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
WHERE LgBewCod.Code IN (N'INV', N'DINV')
  AND LagerBew.Zeitpunkt BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Lagerart.ID IN ($3$)
  AND (($4$ = 1 AND LagerBew.Differenz != 0) OR $4$ = 0)
  AND (($5$ = 1 AND (LagerBew.BestandNeu != 0 OR LagerBew.Differenz != 0)) OR $5$ = 0)
GROUP BY Standort.SuchCode, Lagerart.LagerartBez$LAN$, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Bestand.ID, Artikel.GroeKoID;

WITH FirstLagerBewTime AS (
  SELECT LagerBew.BestandID, MIN(LagerBew.Zeitpunkt) AS Zeitpunkt
  FROM LagerBew
  JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
  WHERE LgBewCod.Code IN (N'INV', N'DINV')
    AND LagerBew.Zeitpunkt BETWEEN $STARTDATE$ AND $ENDDATE$
  GROUP BY LagerBew.BestandID
)
UPDATE InvResult SET [Bestand vor Inventur] = LagerBew.BestandNeu - LagerBew.Differenz
FROM #InvResult AS InvResult
JOIN FirstLagerBewTime ON FirstLagerBewTime.BestandID = InvResult.BestandID
JOIN LagerBew ON FirstLagerBewTime.BestandID = LagerBew.BestandID AND FirstLagerBewTime.Zeitpunkt = LagerBew.Zeitpunkt;

WITH LastLagerBewTime AS (
  SELECT LagerBew.BestandID, MAX(LagerBew.Zeitpunkt) AS Zeitpunkt
  FROM LagerBew
  JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
  WHERE LgBewCod.Code IN (N'INV', N'DINV')
    AND LagerBew.Zeitpunkt BETWEEN $STARTDATE$ AND $ENDDATE$
  GROUP BY LagerBew.BestandID
)
UPDATE InvResult SET [Bestand nach Inventur] = LagerBew.BestandNeu
FROM #InvResult AS InvResult
JOIN LastLagerBewTime ON LastLagerBewTime.BestandID = InvResult.BestandID
JOIN LagerBew ON LastLagerBewTime.BestandID = LagerBew.BestandID AND LastLagerBewTime.Zeitpunkt = LagerBew.Zeitpunkt;

SELECT InvResult.* 
FROM #InvResult AS InvResult
JOIN GroePo ON InvResult.GroeKoID = GroePo.GroeKoID AND InvResult.Größe = GroePo.Groesse
ORDER BY Lagerstandort, Lagerart, ArtikelNr, GroePo.Folge;