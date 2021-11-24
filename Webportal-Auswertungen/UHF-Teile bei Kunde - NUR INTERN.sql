DECLARE @kundenid int = $kundenID;
DECLARE @webuserid int = $webuserID;

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
WITH LiefScan AS (
  SELECT OPScans.OPTeileID, OPScans.LsPoID, OPScans.Zeitpunkt
  FROM dbo.OPScans
  JOIN (
    SELECT OPScans.OPTeileID, MAX(OPScans.ID) AS LiefScanID
    FROM dbo.OPScans
    WHERE OPScans.LsPoID > 0
    GROUP BY OPScans.OPTeileID
  ) AS LastLiefScan ON LastLiefScan.LiefScanID = OPScans.ID
),
EmpfangScan AS (
  SELECT OPScans.OPTeileID, OPScans.Zeitpunkt
  FROM dbo.OPScans
  JOIN (
    SELECT OPScans.OPTeileID, MAX(OPScans.ID) AS EmpfangScanID
    FROM dbo.OPScans
    WHERE OPScans.ActionsID = 136
    GROUP BY OPScans.OPTeileID
  ) AS LastEmpfangScan ON LastEmpfangScan.EmpfangScanID = OPScans.ID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, OPTeile.Code AS [EPC-Code], LsKo.Datum AS Lieferdatum, IIF(DATEDIFF(day, LsKo.Datum, GETDATE()) < 0, 0, DATEDIFF(day, LsKo.Datum, GETDATE())) AS [Tage seit Lieferung], OPTeile.LastScanToKunde AS [Zeitpunkt Auslesen], DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) AS [Tage seit Auslesen], EmpfangScan.Zeitpunkt AS [Zeitpunkt Empfang bei Kunde]
FROM dbo.OPTeile
JOIN dbo.Vsa ON OPTeile.VsaID = Vsa.ID
JOIN dbo.Kunden ON Vsa.KundenID = Kunden.ID
JOIN dbo.Abteil ON Vsa.AbteilID = Abteil.ID
JOIN dbo.ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN dbo.Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN dbo.GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
JOIN LiefScan ON LiefScan.OPTeileID = OPTeile.ID
JOIN dbo.LsPo ON LiefScan.LsPoID = LsPo.ID
JOIN dbo.LsKo ON LsPo.LsKoID = LsKo.ID
LEFT JOIN EmpfangScan ON EmpfangScan.OPTeileID = OPTeile.ID AND EmpfangScan.Zeitpunkt > OPTeile.LastScanToKunde
WHERE Kunden.ID = ' + CAST(@kundenid AS nvarchar) + N'
  AND Vsa.ID IN (  
    SELECT Vsa.ID
    FROM dbo.Vsa
    JOIN dbo.WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN dbo.WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = ' + CAST(@webuserid AS nvarchar) + N'
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  )
  AND Abteil.ID IN (  
    SELECT WebUAbt.AbteilID
    FROM dbo.WebUAbt
    WHERE WebUAbt.WebUserID = ' + CAST(@webuserid AS nvarchar) + N'
  )
  AND OPTeile.LastActionsID IN (102, 120, 136)
  AND OPTeile.Status = N''Q''
ORDER BY KdNr, [VSA-Nr], Kostenstelle, ArtikelNr, GroePo.Folge;';

EXEC sp_executesql @sqltext, N'@kundenid int, @webuserid int', @kundenid, @webuserid;