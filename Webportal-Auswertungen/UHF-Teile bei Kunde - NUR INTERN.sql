DECLARE @kundenid int = $kundenID;
DECLARE @webuserid int = $webuserID;

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
WITH LiefScan AS (
  SELECT Scans.EinzTeilID, Scans.LsPoID, Scans.Zeitpunkt
  FROM Scans
  JOIN (
    SELECT Scans.EinzTeilID, MAX(Scans.ID) AS LiefScanID
    FROM Scans
    WHERE Scans.LsPoID > 0
    GROUP BY Scans.EinzTeilID
  ) AS LastLiefScan ON LastLiefScan.LiefScanID = Scans.ID
),
EmpfangScan AS (
  SELECT Scans.EinzTeilID, Scans.Zeitpunkt
  FROM Scans
  JOIN (
    SELECT Scans.EinzTeilID, MAX(Scans.ID) AS EmpfangScanID
    FROM Scans
    WHERE Scans.ActionsID = 136
    GROUP BY Scans.EinzTeilID
  ) AS LastEmpfangScan ON LastEmpfangScan.EmpfangScanID = Scans.ID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Groesse, EinzTeil.Code AS [EPC-Code], LsKo.Datum AS Lieferdatum, EinzTeil.LastScanToKunde AS [Zeitpunkt Auslesen], DATEDIFF(day, EinzTeil.LastScanToKunde, GETDATE()) AS [Tage seit Auslesen], EmpfangScan.Zeitpunkt AS [Zeitpunkt Empfang bei Kunde], EinzTeil.LastScanTime AS [letzter Scan], DATEDIFF(day, EinzTeil.LastScanTime, GETDATE()) AS [Tage seit letztem Scan]
FROM EinzTeil
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
JOIN LiefScan ON LiefScan.EinzTeilID = EinzTeil.ID
JOIN LsPo ON LiefScan.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
LEFT JOIN EmpfangScan ON EmpfangScan.EinzTeilID = EinzTeil.ID AND EmpfangScan.Zeitpunkt > EinzTeil.LastScanToKunde
WHERE Kunden.ID = @kundenid
  AND EinzTeil.VsaID IN (  
    SELECT Vsa.ID
    FROM Vsa
    JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = @webuserid
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  )
  AND Abteil.ID IN (  
    SELECT WebUAbt.AbteilID
    FROM WebUAbt
    WHERE WebUAbt.WebUserID = @webuserid
  )
  AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136)
  AND EinzTeil.Status = N''Q''
ORDER BY KdNr, [VSA-Nr], Kostenstelle, ArtikelNr, GroePo.Folge;';

EXEC sp_executesql @sqltext, N'@kundenid int, @webuserid int', @kundenid, @webuserid;