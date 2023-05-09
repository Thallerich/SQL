DECLARE @von date = $STARTDATE$;
DECLARE @bis date = $ENDDATE$;
DECLARE @kundenid int = $ID$;
DECLARE @pivotcolumns nvarchar(max);
DECLARE @pivotsumcol nvarchar(max);
DECLARE @pivotsql nvarchar(max);

DECLARE @DateRange TABLE (
  Datum date
);

WITH DateRangeCTE AS (
  SELECT @von AS Datum
  UNION ALL
  SELECT DATEADD(day, 1, Datum) AS Datum
  FROM DateRangeCTE
  WHERE DATEADD(day, 1, Datum) <= @bis
)
INSERT INTO @DateRange (Datum)
SELECT Datum
FROM DateRangeCTE
OPTION (MAXRECURSION 0);

SET @pivotcolumns = STUFF((SELECT DISTINCT ', [' + FORMAT(Datum, N'dd.MM.yyyy', N'de-AT') + ']' FROM @DateRange FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
SET @pivotsumcol = STUFF((SELECT DISTINCT '+ ISNULL([' + FORMAT(Datum, N'dd.MM.yyyy', N'de-AT') + '], 0) ' FROM @DateRange FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');

SET @pivotsql = N'
SELECT KdNr, Kunde, VsaNr, VsaBez AS [Vsa-Bezeichnung], ArtikelNr, Artikelbezeichnung, Größe, ' + @pivotcolumns + ',
  Gesamt = ' + @pivotsumcol + N'
FROM (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], FORMAT(LsKo.Datum, N''dd.MM.yyyy'', N''de-AT'') AS Datum, SUM(LsPo.Menge) AS Liefermenge, GroePo.Folge AS GroesseFolge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Abteil ON LsPo.AbteilID = Abteil.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
  JOIN Standort AS Expedition ON Fahrt.ExpeditionID = Expedition.ID
  JOIN ArtGroe ON LsPo.ArtGroeID = ArtGroe.ID
  JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
  WHERE LsKo.Datum BETWEEN @von AND @bis
    AND Kunden.ID = @kundenid
  GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.Vsanr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, FORMAT(LsKo.Datum, N''dd.MM.yyyy'', N''de-AT''), GroePo.Folge
) AS PivoData
PIVOT (SUM(Liefermenge) FOR Datum IN (' + @pivotcolumns + N')) AS LiefermengenPivot
ORDER BY KdNr, VsaNr, ArtikelNr, GroesseFolge;';

EXEC sp_executesql @pivotsql, N'@von date, @bis date, @kundenid int', @von, @bis, @kundenid;