DECLARE @kundenid int = $kundenID;
DECLARE @webuserid int = $webuserID;

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, COUNT(OPTeile.ID) AS [Anzahl Teile]
FROM dbo.OPTeile
JOIN dbo.Vsa ON OPTeile.VsaID = Vsa.ID
JOIN dbo.Kunden ON Vsa.KundenID = Kunden.ID
JOIN dbo.Abteil ON Vsa.AbteilID = Abteil.ID
JOIN dbo.ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN dbo.Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN dbo.GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
WHERE Kunden.ID = @kundenid
  AND Vsa.ID IN (  
    SELECT Vsa.ID
    FROM dbo.Vsa
    JOIN dbo.WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN dbo.WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = @webuserid
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  )
  AND Abteil.ID IN (  
    SELECT WebUAbt.AbteilID
    FROM dbo.WebUAbt
    WHERE WebUAbt.WebUserID = @webuserid
  )
  AND OPTeile.LastActionsID IN (2, 102, 120, 129, 130, 136)
  AND OPTeile.Status = N''Q''
  AND Artikel.BereichID NOT IN (SELECT ID FROM Bereich WHERE Bereich IN (N''LW'', N''ST'')) 
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, GroePo.Folge
ORDER BY KdNr, [VSA-Nr], Kostenstelle, ArtikelNr, GroePo.Folge;';

EXEC sp_executesql @sqltext, N'@kundenid int, @webuserid int', @kundenid, @webuserid;