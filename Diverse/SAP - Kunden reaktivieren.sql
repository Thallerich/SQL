DECLARE @Customer TABLE (
  CustomerNumber int,
  CustomerID int
);

DECLARE @Reactivated TABLE (
  KdNr int
);

INSERT INTO @Customer (CustomerNumber)
SELECT TRY_CAST(SUBSTRING(SalExLog.HTTPRequest, CHARINDEX(N'<Number>', SalExLog.HTTPRequest, 1) + 8, CHARINDEX(N'</Number>', SalExLog.HTTPRequest, 1) - (CHARINDEX(N'<Number>', SalExLog.HTTPRequest, 1) + 8)) AS int) AS KdNr
FROM SalExLog
WHERE SalExLog.FunctionName = N'Customer'
  AND SalExLog.Anlage_ > N'2023-07-13 10:00:00'
  AND SalExLog.HTTPRequest LIKE N'%<Status>I</Status>%';

UPDATE @Customer SET CustomerID = Kunden.ID
FROM Kunden
WHERE [@Customer].[CustomerNumber] = Kunden.KdNr;

UPDATE Kunden SET [Status] = N'A'
OUTPUT inserted.KdNr INTO @Reactivated (KdNr)
WHERE Kunden.ID IN (SELECT CustomerID FROM @Customer)
  AND Kunden.[Status] = N'I'
  AND EXISTS (
    SELECT History.*
    FROM History
    JOIN Vsa ON History.TableID = Vsa.ID AND History.TableName = N'VSA'
    WHERE Vsa.KundenID = Kunden.ID
      AND History.AnlageUserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'SAP')
      AND History.Anlage_ > N'2023-07-13 10:00:00'
  );

UPDATE KdBer SET [Status] = N'A'
WHERE KdBer.KundenID IN (SELECT CustomerID FROM @Customer)
  AND KdBer.[Status] = N'I'
  AND EXISTS (
    SELECT History.*
    FROM History
    JOIN Vsa ON History.TableID = Vsa.ID AND History.TableName = N'VSA'
    WHERE Vsa.KundenID = KdBer.KundenID
      AND History.AnlageUserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'SAP')
      AND History.Anlage_ > N'2023-07-13 10:00:00'
  );

UPDATE Vertrag SET [Status] = N'A'
WHERE Vertrag.KundenID IN (SELECT CustomerID FROM @Customer)
  AND Vertrag.[Status] = N'I'
  AND EXISTS (
    SELECT History.*
    FROM History
    JOIN Vsa ON History.TableID = Vsa.ID AND History.TableName = N'VSA'
    WHERE Vsa.KundenID = Vertrag.KundenID
      AND History.AnlageUserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'SAP')
      AND History.Anlage_ > N'2023-07-13 10:00:00'
  );

UPDATE Vsa SET [Status] = N'A'
WHERE Vsa.KundenID IN (SELECT CustomerID FROM @Customer)
  AND Vsa.[Status] = N'I'
  AND EXISTS (
    SELECT History.*
    FROM History
    WHERE History.TableID = Vsa.ID
      AND History.TableName = N'VSA'
      AND History.AnlageUserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'SAP')
      AND History.Anlage_ > N'2023-07-13 10:00:00'
  );

SELECT KdNr
FROM @Reactivated;

GO