DECLARE @KdArtiID int = $ID$;
DECLARE @Param1 int = $1$;
DECLARE @Param2 int = $2$;

DECLARE @SQL nvarchar(max);
DECLARE @SelectWearer nvarchar(max) = N'';
DECLARE @ListOrder nvarchar(max) = N'';

SET @SelectWearer = 
CASE @Param1
  WHEN 1 THEN N'  AND Traeger.Status = N''A'''
  WHEN 2 THEN N'  AND Traeger.Status = N''I'''
  ELSE N'  '
END;

SET @ListOrder = 
CASE @Param2
  WHEN 1 THEN N'ORDER BY KundenID, VsaID, TraegerNr, ArtikelNr, Groesse'
  WHEN 2 THEN N'ORDER BY KundenID, VsaID, HatSchrank, SchrankFach, TraegerNr, ArtikelNr, Groesse'
  WHEN 3 THEN N'ORDER BY KundenID, VsaID, Nachname, Vorname, TraegerNr, ArtikelNr, Groesse'
  WHEN 4 THEN N'ORDER BY KundenID, VsaID, TraegerNr, Ausgang1 DESC, ArtikelNr, Groesse'
END;

SET @SQL = N'
WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N''EINZHIST'')
)
SELECT Kunden.ID AS KundenID, Kunden.KdNr, Vsa.ID AS VsaID, Vsa.VsaNr, Traeger.ID AS TraegerID, Traeger.Traeger AS TraegerNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.ID AS ArtGroeID, ArtGroe.Groesse, EinzHist.Barcode, Teilestatus.StatusBez AS Teilestatus, EinzHist.Indienst, EinzHist.Ausdienst, EinzHist.Ausgang1, EinzHist.RuecklaufK AS WaschzyklenKunde, EinzHist.TeileSchrankInfo AS SchrankFach, IIF(EinzHist.TeileSchrankInfo IS NULL, 0, 1) AS HatSchrank, IIF(EinzHist.Status IN (''Q'', ''S'', ''U'', ''W''), 1, 0) AS Istmenge, IIF(EinzHist.Status <= ''Q'' AND EinzHist.Status >= ''A'', 1, 0) AS Sollmenge
FROM EinzHist
JOIN Teilestatus ON EinzHist.Status = Teilestatus.Status
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE KdArti.ID = ' + CAST(@KdArtiID AS nvarchar(max)) + '
  AND EinzHist.Status IN (''A'',''E'',''G'',''I'',''K'',''L'',''M'',''O'',''Q'',''S'',''N'')
' + @SelectWearer + CHAR(13) + CHAR(10) + @ListOrder + N';';

EXEC sp_executesql @SQL;