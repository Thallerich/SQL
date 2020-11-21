-- ########################  Excel-Liste impoortieren ########################################
-- ########################  Liste mit 2 Spalten - KdNr und Chipcode #########################

DROP TABLE IF EXISTS __Schwundliste;

DECLARE @ImportFile nvarchar(200) = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\LKHollabrunnSchwund.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);

CREATE TABLE __Schwundliste (
  KdNr int,
  Code nvarchar(33) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT * ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Schwund$]);';

INSERT INTO __Schwundliste
EXEC sp_executesql @XLSXImportSQL;

-- ######################## Auswertungen ########################################

WITH Poolstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'OPTEILE')
)
SELECT SchwundTeile.Code, Poolstatus.StatusBez AS Teilestatus, OPTeile.LastScanToKunde AS [letzte Ausgang zum Kunden], OPTeile.LastScanTime AS [letzter Scan], Kunden.KdNr AS [aktueller Kunde], DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) AS [Tage beim Kunden], DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) AS [Tage seit letztem Scan]
FROM __Schwundliste AS SchwundTeile
JOIN OPTeile ON SchwundTeile.Code = OPTeile.Code
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Poolstatus ON OPTeile.[Status] = Poolstatus.[Status]
WHERE SchwundTeile.KdNr = Kunden.KdNr;

WITH Schwund AS (
  SELECT OPTeile.VsaID, OPTeile.ArtGroeID, OPTeile.ArtikelID, COUNT(DISTINCT OPTeile.ID) AS Schwundmenge
  FROM __Schwundliste AS SchwundTeile
  JOIN OPTeile ON SchwundTeile.Code = OPTeile.Code
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE SchwundTeile.KdNr = Kunden.KdNr
  GROUP BY OPTeile.VsaID, OPTeile.ArtGroeID, OPTeile.ArtikelID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, VsaAnf.Bestand AS [Vertragsbestand aktuell], VsaAnf.BestandIst AS [Ist-Bestand aktuell], Schwund.Schwundmenge, IIF( (VsaAnf.Bestand - Schwund.Schwundmenge) - ((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge) + IIF((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge = 0, 0, Artikel.Packmenge) < 0, 0,  (VsaAnf.Bestand - Schwund.Schwundmenge) - ((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge) + IIF((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge = 0, 0, Artikel.Packmenge)) AS [Vertragsbestand neu]
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Schwund ON Schwund.VsaID = Vsa.ID AND (Schwund.ArtGroeID = VsaAnf.ArtGroeID OR VsaAnf.ArtGroeID = -1) AND Schwund.ArtikelID = Artikel.ID;

-- ########################  Schwundbuchung durchführen ########################################

DROP TABLE IF EXISTS __Schwundbuchung;

CREATE TABLE __Schwundbuchung (
  OPTeileID int,
  ArtGroeID int,
  ArtikelID int,
  VsaID int
);

UPDATE OPTeile SET [Status] = N'W',LastActionsID = 116, RechPoID = -2
OUTPUT inserted.ID, inserted.ArtGroeID, inserted.ArtikelID, inserted.VsaID
INTO __Schwundbuchung
WHERE OPTeile.ID IN (
  SELECT OPTeile.ID
  FROM OPTeile
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Kunden.KdNr IN (SELECT DISTINCT KdNr FROM __Schwundliste)
    AND DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) > 90
    AND OPTeile.Status < N'W'
);

UPDATE OPTeile SET RechPoID = -1
WHERE OPTeile.ID IN (SELECT OPTeileID FROM __Schwundbuchung)
  AND (
    OPTeile.ID IN (
      SELECT OPTeile.ID
      FROM OPTeile
      WHERE OPTeile.Code IN (SELECT Code FROM __Schwundliste)
    )
    OR
    OPTeile.ID IN (
      SELECT OPTeile.ID
      FROM OPTeile
      WHERE OPTeile.LastScanTime > N'2020-09-29 23:59:59'
    )
  );

-- ########################  System-Checkliste 174 ausführen, um Ist-Bestand anzupassen ########

-- ########################  Vertragsbestände entsprechend reduzieren ##########################

WITH Schwund AS (
  SELECT __Schwundbuchung.VsaID, __Schwundbuchung.ArtGroeID, __Schwundbuchung.ArtikelID, COUNT(DISTINCT __Schwundbuchung.OPTeileID) AS Schwundmenge
  FROM __Schwundbuchung
  GROUP BY __Schwundbuchung.VsaID, __Schwundbuchung.ArtGroeID, __Schwundbuchung.ArtikelID
)
UPDATE VsaAnf SET Bestand = IIF((VsaAnf.Bestand - Schwund.Schwundmenge) - ((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge) + IIF((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge = 0, 0, Artikel.Packmenge) < 0, 0,  (VsaAnf.Bestand - Schwund.Schwundmenge) - ((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge) + IIF((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge = 0, 0, Artikel.Packmenge))
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Schwund ON Schwund.VsaID = Vsa.ID AND (Schwund.ArtGroeID = VsaAnf.ArtGroeID OR VsaAnf.ArtGroeID = -1) AND Schwund.ArtikelID = Artikel.ID;