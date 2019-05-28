DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01.wozabal.int\AdvanTex\Temp\Chips2.xlsx';  -- Pfad zum Excel-File mit den Teile-Daten. Muss für den SQL-Server-Prozess zugreifbar sein, daher am Besten unter \\atenadvantex01\advantex\temp\ ablegen.
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTableDouble TABLE (
  ArtikelID int,
  Hexcode nvarchar(33) COLLATE Latin1_General_CS_AS
);

DECLARE @ImportTableShipped TABLE (
  AuftragsNr nvarchar(20) COLLATE Latin1_General_CS_AS,
  Kommissionierdatum datetime,
  Hexcode nvarchar(33) COLLATE Latin1_General_CS_AS,
  Kunde nvarchar(20) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT CAST(ArtikelID AS int) AS ArtikelID, ' +
  N'CAST(Hex AS nvarchar(33)) AS Hexcode ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [double$]);';

INSERT INTO @ImportTableDouble
EXEC sp_executesql @XLSXImportSQL;

SET @XLSXImportSQL = N'SELECT CAST(Packzettel AS nvarchar(20)) AS AuftragsNr, ' +
  N'CAST(Kommissionierdatum AS datetime) AS Kommissionierdatum, ' +
  N'CAST(Hexcode AS nvarchar(33)) AS Hexcode, ' +
  N'CAST(Kunde AS nvarchar(20)) AS Kunde ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [shipped$]);';

INSERT INTO @ImportTableShipped
EXEC sp_executesql @XLSXImportSQL;

/* Auswertung ungleicher Artikel CIT <-> AdvanTex */
/* 
SELECT OPTeile.Code AS CodeAdvantex, DoubleChip.Hexcode AS CodeCIT, AdvantexArtikel.ArtikelNr AS ArtikelNrAdvantex, CITArtikel.ArtikelNr AS ArtikelNrCIT
FROM OPTeile
JOIN @ImportTableDouble AS DoubleChip ON OPTeile.Code = DoubleChip.Hexcode
JOIN Artikel AS AdvantexArtikel ON OPTeile.ArtikelID = AdvantexArtikel.ID
JOIN Artikel AS CITArtikel ON DoubleChip.ArtikelID = CITArtikel.ID
WHERE OPTeile.ArtikelID <> DoubleChip.ArtikelID;
 */

/* Auswertung Ort der doppelten Teile */
/* 
 SELECT OPTeile.Code, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, IIF(OPTeile.LastActionsID = 102, N'beim Kunden', N'im Betrieb') AS [Ort des Teils], IIF(OPTeile.VsaID > 0 AND OPTeile.LastActionsID = 102, Kunden.KdNr, NULL) AS KdNr, IIF(OPTeile.VsaID > 0 AND OPTeile.LastActionsID = 102, Kunden.SuchCode, NULL) AS Kunde
 FROM OPTeile
 JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
 JOIN Vsa ON OPTeile.VsaID = Vsa.ID
 JOIN Kunden ON Vsa.KundenID = Kunden.ID
 WHERE OPTeile.Code IN (SELECT Hexcode FROM @ImportTableDouble);
  */

SELECT OPTeile.ID AS OPTeileID, OPTeile.Status, OPTeile.Code, OPTeile.WegDatum, Kunden.KdNr AS AdvKdNr, Vsa.VsaNr AS AdvVsaNr, Kunden.SuchCode AS AdvKunde, ImportTableShipped.Kunde AS CITKundeListe, ImportTableShipped.AuftragsNr AS Packzettel, CITKunden.KdNr AS CITKdNr, CITKunden.SuchCode AS CITKunde, CITVsa.VsaNr AS CITVsaNr, OPTeile.WegGrundID
FROM OPTeile
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN @ImportTableShipped AS ImportTableShipped ON OPTeile.Code = ImportTableShipped.Hexcode
LEFT OUTER JOIN AnfKo ON ImportTableShipped.AuftragsNr = AnfKo.AuftragsNr
LEFT OUTER JOIN Vsa AS CITVsa ON AnfKo.VsaID = CITVsa.ID
LEFT OUTER JOIN Kunden AS CITKunden ON CITVsa.KundenID = CITKunden.ID
WHERE OPTeile.Status = N'Z'
  AND OPTeile.WegDatum BETWEEN N'2019-05-27' AND N'2019-05-28';