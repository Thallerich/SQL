DECLARE @currentweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);
DECLARE @customernumber int = 272606;
DECLARE @barcodetable nvarchar(20) = N'_IT66381_Barcodes';

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N''EINZHIST''
)
SELECT Holding.Holding, Kunden.KdNr, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], Schrank.SchrankNr AS Schrank, TraeFach.Fach, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Barcode, EinzHist.Eingang1 AS [letzter Eingang], EinzHist.Ausgang1 AS [letzter Ausgang], Teilestatus.StatusBez AS Teilestatus, EinzHist.AlterInfo AS [Alter in Wochen], TeileRestwert.RestwertInfo AS Restwert
FROM EinzHist
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
LEFT JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
LEFT JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
JOIN Teilestatus ON Teilestatus.Status = EinzHist.Status
JOIN [Week] ON DATEADD(day, EinzHist.AnzTageImLager, EinzHist.ErstDatum) BETWEEN [Week].VonDat AND [Week].BisDat
CROSS APPLY funcGetRestwert(EinzHist.ID, @currentweek, 1) AS TeileRestwert
WHERE EinzHist.Barcode IN (SELECT Barcode COLLATE Latin1_General_CS_AS FROM ' + @barcodetable + ')
  AND EinzHist.Status BETWEEN N''Q'' AND N''W''
  AND EinzHist.Einzug IS NULL
  AND EinzHist.IsCurrEinzHist = 1
  AND Kunden.KdNr = @customernumber;
';

EXEC sp_executesql @sqltext, N'@currentweek nchar(7), @customernumber int', @currentweek, @customernumber;