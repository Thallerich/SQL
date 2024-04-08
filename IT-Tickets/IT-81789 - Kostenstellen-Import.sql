DECLARE @customerid int = (SELECT ID FROM Kunden WHERE KdNr = 10007241);
DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO Abteil (KundenID, Abteilung, Bez, AnlageUserID_, UserID_)
SELECT x.KundenID, IIF(RowNumber > 1, CONCAT(x.Abteilung, N'_', CAST(x.RowNumber AS nvarchar)), x.Abteilung) AS Abteilung, x.Bez, x.AnlageUserID_, x.UserID_
FROM (
  SELECT @customerid AS KundenID, IIF(LEN(_IT81790.KoSt) < 4, RIGHT(CONCAT(REPLICATE(N'0', 4), _IT81790.KoSt), 4), _IT81790.KoSt) AS Abteilung, _IT81790.[Kostenstelle (Bezeichnung)] AS Bez, @userid AS AnlageUserID_, @userid AS UserID_, ROW_NUMBER() OVER (PARTITION BY IIF(LEN(_IT81790.KoSt) < 4, RIGHT(CONCAT(REPLICATE(N'0', 4), _IT81790.KoSt), 4), _IT81790.KoSt) ORDER BY _IT81790.KoSt) AS RowNumber
  FROM _IT81790
) AS x
WHERE NOT EXISTS (
  SELECT Abteil.*
  FROM Abteil
  WHERE Abteil.KundenID = x.KundenID
    AND Abteil.Abteilung = x.Abteilung COLLATE Latin1_General_CS_AS
);

GO