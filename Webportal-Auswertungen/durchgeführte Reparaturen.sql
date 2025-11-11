DECLARE @kundenid int = $kundenID;
DECLARE @webuserid int = $webuserID;

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
SELECT EinzHist.Barcode, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Bezeichnung, ArtGroe.Groesse, EinzHist.Eingang1 AS [letzter Eingang Salesianer], EinzHist.Ausgang1 AS [letzte Lieferung], RepType.ArtikelBez AS Reparatur, TeilSoFa.Zeitpunkt
FROM TeilSoFa
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON ArtGroe.Groesse = GroePo.Groesse AND Artikel.GroeKoID = GroePo.GroeKoID
JOIN Artikel AS RepType ON TeilSoFa.ArtikelID = RepType.ID
WHERE RepType.ArtiTypeID = 5
  AND EinzHist.KundenID = @kundenid
  AND Traeger.VsaID IN (
    SELECT Vsa.ID
    FROM Vsa
    JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = @webuserID
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  )
  AND Traeger.AbteilID IN (
    SELECT WebUAbt.AbteilID
      FROM WebUAbt
      WHERE WebUAbt.WebUserID =  @webuserID
  )
ORDER BY Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, GroePo.Folge;';

EXEC sp_executesql @sqltext, N'@kundenid int, @webuserid int', @kundenid, @webuserid;