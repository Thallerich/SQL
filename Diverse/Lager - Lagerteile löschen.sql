DECLARE @Bestand TABLE (
  BestandID int PRIMARY KEY
);

DECLARE @Lagerteil TABLE (
  TeileLagID int PRIMARY KEY
);

INSERT INTO @Bestand (BestandID)
SELECT Bestand.ID
FROM Bestand
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
WHERE Artikel.ArtikelNr IN (N'P7WM', N'P4WM')
  AND Lager.SuchCode = N'INZ'
  AND Bestand.Bestand != 0
  AND Lagerart.LagerortModus IN (1, 2);

INSERT INTO @Lagerteil (TeileLagID)
SELECT TeileLag.ID
FROM TeileLag
JOIN Bestand ON Bestand.ArtGroeID = TeileLag.ArtGroeID AND Bestand.LagerArtID = TeileLag.LagerArtID
WHERE Bestand.ID IN (
  SELECT BestandID
  FROM @Bestand
);

BEGIN TRANSACTION
  DELETE FROM TeileLAp
  WHERE TeileLagID IN (
    SELECT TeileLagID
    FROM @Lagerteil
  );

  DELETE FROM TeileLag
  WHERE ID IN (
    SELECT TeileLagID
    FROM @Lagerteil
  );
COMMIT;
--ROLLBACK;

SELECT N'BESTANDANLAGERANGLEICHEN;' + CAST(BestandID AS nvarchar) AS ModuleCall
FROM @Bestand;

GO