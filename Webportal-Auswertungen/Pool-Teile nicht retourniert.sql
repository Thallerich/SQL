WITH LastScan AS (
  SELECT Scans.TeileID, MAX(Scans.ID) AS ScanID
  FROM Scans
  WHERE Scans.ActionsID = 135  -- Action Ausgabe an Pool-Träger
  GROUP BY Scans.TeileID
)
SELECT Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, CAST(Scans.[DateTime] AS date) AS Ausgabedatum, Scans.Info AS [Träger laut Webportal]
FROM Teile
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN LastScan ON LastScan.TeileID = Teile.ID
JOIN Scans ON LastScan.ScanID = Scans.ID
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Teile.LastActionsID = 135  -- Action Ausgabe an Pool-Träger
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