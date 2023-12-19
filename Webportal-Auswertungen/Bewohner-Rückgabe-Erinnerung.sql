DECLARE @kundenid int = $kundenID, @webuserid int = $webuserID, @sqltext nvarchar(max);

SET @sqltext = N'
  SELECT Vsa.VsaNr AS [VSA-Nr.],
    CONCAT_WS('' '', Vsa.Name1, Vsa.Name2, Vsa.Name3) AS Versandanschrift,
    CONCAT_WS('' '', Vsa.PLZ, Vsa.Ort) AS [PLZ/Ort],
    Traeger.Traeger AS [Träger-Nr.],
    Traeger.Nachname,
    Traeger.Vorname,
    Artikel.ArtikelNr AS [Artikel-Nr.],
    Artikel.ArtikelBez AS Artikel,
    ArtGroe.Groesse AS Größe,
    EinzHist.Barcode,
    EinzHist.Indienst AS Startwoche,
    EinzHist.AbmeldDat AS Abmeldetermin
  FROM EinzTeil
  JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
  JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
  JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  WHERE EinzHist.[Status] = N''W''
    AND EinzHist.Einzug IS NULL
    AND EinzTeil.AltenheimModus = 1
    AND KdBer.RWBerechnungAlleTeile = 1
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
    );
';

EXEC sp_executesql @sqltext, N'@kundenid int, @webuserid int', @kundenid, @webuserid;