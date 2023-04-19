DECLARE @kundenid int = $kundenID;
DECLARE @webuserid int = $webuserID;

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
SELECT Vsa.VsaNr AS [VSA-Nr.], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS [Träger-Nr.], Traeger.Nachname, Traeger.Vorname, EinzHist.Barcode, Artikel.ArtikelNr AS [Artikel-Nr.], Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Eingang1 AS [letzter Eingang], EinzHist.Ausgang1 AS [letzter Ausgang]
FROM EinzHist
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON ArtGroe.Groesse = GroePo.Groesse AND Artikel.GroeKoID = GroePo.GroeKoID
WHERE EinzHist.IsCurrEinzHist = 1
  AND EinzHist.PoolFkt = 0
  AND EinzHist.[Status] = N''Q''
  AND EinzTeil.AltenheimModus = 0
  AND Vsa.KundenID = @kundenid
  AND Vsa.ID IN (  
    SELECT Vsa.ID
    FROM Vsa
    JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = @webuserid
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  )
  AND Traeger.AbteilID IN (  
    SELECT WebUAbt.AbteilID
    FROM WebUAbt
    WHERE WebUAbt.WebUserID = @webuserid
  )
ORDER BY [Vsa-Nr.], Nachname, ArtikelNr, GroePo.Folge;
';

EXEC sp_executesql @sqltext, N'@kundenid int, @webuserid int', @kundenid, @webuserid;