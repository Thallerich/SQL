DECLARE @DateSelection date = $1$;

DECLARE @Barcode varchar(33);
DECLARE @ArtikelNr nchar(15);
DECLARE @Artikelbezeichnung nvarchar(60);
DECLARE @Groesse nchar(10);
DECLARE @TeileID int;
DECLARE @ScanID int;
DECLARE @Eingangsscan datetime;
DECLARE @Abholung date;

DECLARE curTeile CURSOR FOR
SELECT Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Teile.ID AS TeileID
FROM Teile
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.ID = $2$
  AND EXISTS (
    SELECT Scans.*
    FROM Scans
    WHERE Scans.TeileID = Teile.ID
      AND Scans.Menge <> 0
      AND Scans.[DateTime] > @DateSelection
  );

DROP TABLE IF EXISTS #TeileInOut;

CREATE TABLE #TeileInOut (
  Barcode varchar(33),
  ArtikelNr nchar(15),
  Artikelbezeichnung nvarchar(60),
  Groesse nchar(10),
  Eingangsscan datetime,
  Ausgangsscan datetime,
  Abholung date,
  Lieferung date,
  LsNr int
);

OPEN curTeile;

FETCH NEXT FROM curTeile INTO @Barcode, @ArtikelNr, @Artikelbezeichnung, @Groesse, @TeileID;

WHILE @@FETCH_STATUS = 0
BEGIN
  DECLARE curEingangsscan CURSOR FOR
    SELECT Scans.ID AS ScanID, Scans.[DateTime] AS Eingangsscan, Scans.EinAusDat AS Abholung
    FROM Scans
    WHERE Scans.TeileID = @TeileID
      AND Scans.DateTime > = @DateSelection
      AND Scans.Menge = 1
    ORDER BY Scans.ID ASC;

  OPEN curEingangsscan;

  FETCH NEXT FROM curEingangsscan INTO @ScanID, @Eingangsscan, @Abholung;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #TeileInOut
    SELECT @Barcode, @ArtikelNr, @Artikelbezeichnung, @Groesse, @Eingangsscan, Scans.[DateTime] AS Ausgangsscan, @Abholung, Scans.EinAusDat AS Lieferung, LsKo.LsNr
    FROM Scans
    JOIN LsPo ON Scans.LsPoID = LsPo.ID
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID
    WHERE Scans.ID = (
      SELECT MIN(Scans.ID)
      FROM Scans
      WHERE Scans.TeileID = @TeileID
        AND Scans.Menge = -1
        AND Scans.ID > @ScanID
    );

    FETCH NEXT FROM curEingangsscan INTO @ScanID, @Eingangsscan, @Abholung;
  END;

  CLOSE curEingangsscan;
  DEALLOCATE curEingangsscan;

  FETCH NEXT FROM curTeile INTO @Barcode, @ArtikelNr, @Artikelbezeichnung, @Groesse, @TeileID;
END;

CLOSE curTeile;
DEALLOCATE curTeile;

SELECT * FROM #TeileInOut;