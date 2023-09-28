DECLARE @kundenid int = $kundenID;
DECLARE @webuserid int = $webuserID;
DECLARE @bisdate date = CAST($bisDat AS date);
DECLARE @currentweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
  SELECT Kunden.KdNr,
    Kunden.SuchCode AS Kunde,
    Vsa.VsaNr AS [VSA-Nummer],
    Vsa.SuchCode AS [VSA-Stichwort],
    Vsa.Bez AS [VSA-Bezeichnung],
    Traeger.ID AS BlockID,
    N''Teile'' AS BlockIDName,
    Traeger.Traeger AS [Trägernummer],
    Traeger.Titel,
    Traeger.Vorname,
    Traeger.Nachname,
    Artikel.ArtikelNr AS Artikelnummer,
    Artikel.ArtikelBez AS Artikelbezeichnung,
    EinzHist.Barcode,
    FORMAT(EinzHist.Eingang1, N''d'', N''de-AT'') AS [letzter Eingang],
    FORMAT(EinzHist.Ausgang1, N''d'', N''de-AT'') AS [letzter Ausgang],
    TeileRW.RestwertInfo AS [aktueller Restwert]
  FROM EinzHist
  CROSS APPLY dbo.funcGetRestwert(EinzHist.ID, @currentweek, 1) AS TeileRW
  JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
  JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  WHERE Kunden.ID = @kundenid
    AND EinzHist.Eingang1 < @bisdate
    AND EinzHist.Status = N''Q''
    AND EinzHist.EinzHistTyp = 1
    AND EinzHist.PoolFkt = 0
    AND Traeger.AbteilID IN (
      SELECT WebUAbt.AbteilID
      FROM WebUAbt
      WHERE WebUAbt.WebUserID = @webuserid
    )
  ORDER BY [VSA-Nummer], [Trägernummer], Artikelnummer;
';

EXEC sp_executesql @sqltext, N'@kundenid int, @webuserid int, @bisdate date, @currentweek nchar(7)', @kundenid, @webuserid, @bisdate, @currentweek;