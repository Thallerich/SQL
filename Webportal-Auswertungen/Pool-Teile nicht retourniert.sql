-- {Liste #38}
WITH LastScan AS (
  SELECT Scans.EinzHistID, MAX(Scans.ID) AS ScanID
  FROM Scans
  WHERE Scans.ActionsID = 135  -- Action Ausgabe an Pool-Träger
  GROUP BY Scans.EinzHistID
)
SELECT EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, CAST(Scans.[DateTime] AS date) AS Ausgabedatum, Scans.Info AS [Träger laut Webportal]
FROM EinzHist
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN LastScan ON LastScan.EinzHistID = EinzHist.ID
JOIN Scans ON LastScan.ScanID = Scans.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE EinzHist.LastActionsID = 135  -- Action Ausgabe an Pool-Träger
  AND Kunden.ID = $kundenID
  AND Vsa.ID IN (
    SELECT Vsa.ID
    FROM Vsa
    JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = $webuserID
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  )
  AND Traeger.AbteilID IN (
    SELECT WebUAbt.AbteilID
      FROM WebUAbt
      WHERE WebUAbt.WebUserID =  $webuserID
  );