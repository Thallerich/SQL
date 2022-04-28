DECLARE @Source nchar(8) = N'GR_BST';
DECLARE @Destination nchar(8) = N'GR_NUM_E';
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @GroeKo TABLE (
  ID int
);

BEGIN TRANSACTION;

  INSERT INTO GroeKo (GroeKoCode, GroeKoBez, GroeKoBez1, GroeKoBez2, GroeKoBez3, GroeKoBez4, GroeKoBez5, GroeKoBez6, GroeKoBez7, GroeKoBez8, GroeKoBez9, GroeKoBezA, [Status], Geschlecht, UserID_, AnlageuserID_)
  OUTPUT inserted.ID
  INTO @GroeKo (ID)
  VALUES (@Destination, @Destination, @Destination, @Destination, @Destination, @Destination, @Destination, @Destination, @Destination, @Destination, @Destination, @Destination, N'A', NULL, @UserID, @UserID);

  INSERT INTO GroePo (GroeKoID, [Status], Groesse, Folge, Sondermasse, Gruppe, UserID_, AnlageUserID_)
  SELECT GroeKoDestination.ID AS GroeKoID, GroePo.[Status], GroePo.Groesse, GroePo.Folge, GroePo.Sondermasse, 10 * DENSE_RANK() OVER (ORDER BY Folge, Groesse) AS Gruppe, @UserID AS UserID_, @UserID AS AnlageUserID_
  FROM GroePo
  CROSS JOIN @GroeKo AS GroeKoDestination
  JOIN GroeKo ON GroePo.GroeKoID = GroeKo.ID
  WHERE GroeKo.GroeKoCode = @Source;

COMMIT;