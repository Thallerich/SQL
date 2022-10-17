USE Salesianer;
GO

PRINT N'Creating backup tables!';
GO

IF OBJECT_ID(N'dbo._IT63937_KdBer_Service') IS NULL
BEGIN
  CREATE TABLE _IT63937_KdBer_Service (
    KdBerID int PRIMARY KEY,
    ServiceID int,
    [Timestamp] datetime DEFAULT GETDATE()
  );
END ELSE BEGIN
  PRINT N'KdBer-Backup Table already present!';
END;

GO

IF OBJECT_ID(N'dbo._IT63937_VsaAnf') IS NULL
BEGIN
  SELECT TOP 0 VsaAnf.*
  INTO _IT63937_VsaAnf
  FROM VsaAnf;
END ELSE BEGIN
  PRINT N'VsaAnf-Backup Table already present!';
END;

GO

PRINT N'Creating working tables!';
GO

IF OBJECT_ID(N'tempdb..#KdList') IS NULL
BEGIN
  CREATE TABLE #KdList (
    KundenID int PRIMARY KEY
  );
END ELSE BEGIN
  TRUNCATE TABLE #KdList;
END;

IF OBJECT_ID(N'tempdb..#VsaAnfDelete') IS NULL
BEGIN
  CREATE TABLE #VsaAnfDelete (
    VsaAnfID int PRIMARY KEY
  );
END ELSE BEGIN
  TRUNCATE TABLE #VsaAnfDelete;
END;

GO

PRINT N'Selecting customers!';

INSERT INTO #KdList (KundenID)
SELECT Kunden.ID
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
WHERE Firma.SuchCode = N'FA14'
  AND [Zone].ZonenCode = N'OST';

GO

PRINT N'Selecting VsaAnf';

INSERT INTO #VsaAnfDelete (VsaAnfID)
SELECT VsaAnf.ID
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE KdArti.KundenID IN (
    SELECT KundenID
    FROM #KdList
  )
  AND LEFT(Artikel.ArtikelNr, 2) IN (N'SW', N'SC', N'SV', N'ST');

GO

PRINT N'Emptying customer service user!';

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

UPDATE KdBer SET ServiceID = -1, UserID_ = @UserID
OUTPUT deleted.ID, deleted.ServiceID
INTO _IT63937_KdBer_Service (KdBerID, ServiceID)
WHERE KdBer.KundenID IN (
    SELECT KundenID
    FROM #KdList
  )
  AND KdBer.ServiceID != -1;

GO

PRINT N'Deleting VsaAnf';

DELETE FROM VsaAnfSo
WHERE VsaAnfID IN (
  SELECT VsaAnfID
  FROM #VsaAnfDelete
);

DELETE FROM VsaAnf
OUTPUT deleted.*
INTO _IT63937_VsaAnf
WHERE ID IN (
  SELECT VsaAnfID
  FROM #VsaAnfDelete
);

GO