DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @LsKoReturn TABLE (
  LsKoID int,
  VsaID int,
  Datum date
);

DECLARE @LsPoReturn TABLE (
  LsKoID int,
  LsPoID int,
  KdArtiID int
);

UPDATE _IT73650 SET VsaID = x.VsaID, KdArtiID = x.KdArtiID
FROM (
  SELECT _IT73650.Barcode, EinzHist.VsaID, EinzHist.KdArtiID
  FROM EinzHist
  JOIN _IT73650 ON EinzHist.Barcode = _IT73650.Barcode AND CAST(_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  WHERE EinzHist.EinzHistTyp = 1
) x
WHERE x.Barcode = _IT73650.Barcode;

INSERT INTO LsKo (LsNr, [Status], VsaID, Datum, FahrtID, TourenID, ProduktionID, AnlageUserID_, UserID_)
OUTPUT inserted.ID, inserted.VsaID, inserted.Datum INTO @LsKoReturn (LsKoID, VsaID, Datum)
SELECT LsNr = NEXT VALUE FOR NextID_LSNR, x.[Status], x.VsaID, x.Datum, x.FahrtID, x.TourenID, x.ProduktionID, x.AnlageUserID_, x.UserID_
FROM (
  SELECT DISTINCT CAST(N'Q' AS nchar(1)) AS [Status], EinzHist.VsaID, _IT73650.Abholtag AS Datum, CAST(-1 AS int) AS FahrtID, CAST(-2 AS int) AS TourenID, CAST(4535 AS int) AS ProduktionID, @UserID AS AnlageUserID_, @UserID AS UserID_
  FROM EinzHist
  JOIN _IT73650 ON EinzHist.Barcode = _IT73650.Barcode AND CAST(_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  WHERE EinzHist.EinzHistTyp = 1
) x;

UPDATE _IT73650 SET LsKoID = [@LsKoReturn].[LsKoID]
FROM @LsKoReturn
WHERE _IT73650.VsaID = [@LsKoReturn].VsaID
  AND _IT73650.Abholtag = [@LsKoReturn].Datum;

INSERT INTO LsPo (LsKoID, AbteilID, KdArtiID, Menge, UrMenge, EPreis, WaeKursID, ProduktionID, AnlageUserID_, UserID_)
OUTPUT inserted.LsKoID, inserted.ID, inserted.KdArtiID INTO @LsPoReturn (LsKoID, LsPoID, KdArtiID)
SELECT x.LsKoID, x.AbteilID, x.KdArtiID, SUM(x.Menge) AS Menge, SUM(x.Menge) AS UrMenge, x.EPreis, x.WaeKursID, x.ProduktionID, x.AnlageUserID_, x.UserID_
FROM (
  SELECT _IT73650.LsKoID, Traeger.AbteilID, EinzHist.KdArtiID, CAST(1 AS int) AS Menge, KdArti.WaschPreis AS EPreis, CAST(-2 AS int) AS WaeKursID, CAST(4535 AS int) AS ProduktionID, @UserID AS AnlageUserID_, @UserID AS UserID_
  FROM EinzHist
  JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
  JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
  JOIN _IT73650 ON EinzHist.Barcode = _IT73650.Barcode AND CAST(_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  WHERE EinzHist.EinzHistTyp = 1
) x
GROUP BY x.LsKoID, x.AbteilID, x.KdArtiID, x.EPreis, x.WaeKursID, x.ProduktionID, x.AnlageUserID_, x.UserID_;

UPDATE _IT73650 SET LsPoID = [@LsPoReturn].LsPoID
FROM @LsPoReturn
WHERE [@LsPoReturn].LsKoID = _IT73650.LsKoID AND [@LsPoReturn].KdArtiID = _IT73650.KdArtiID;

INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, Menge, LsPoID, EinAusDat, TraegerID, VsaID, AnlageUserID_, UserID_)
SELECT EinzHist.ID AS EinzHistID, EinzHist.EinzTeilID, DATEADD(hour, 12, CAST(_IT73650.Abholtag AS datetime2)) AS [DateTime], CAST(1 AS int) AS ActionsID, CAST(1 AS int) AS ZielNrID, CAST(2240 AS int) AS ArbPlatzID, CAST(1 AS int) AS Menge, CAST(-1 AS int) AS LsPoID, DATEADD(day, -7, _IT73650.Abholtag) AS EinAusDat, EinzHist.TraegerID, EinzHist.VsaID, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM EinzHist
JOIN _IT73650 ON EinzHist.Barcode = _IT73650.Barcode AND CAST(_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
WHERE EinzHist.EinzHistTyp = 1;

INSERT INTO Scans (EinzHistID, EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, Menge, LsPoID, EinAusDat, TraegerID, VsaID, AnlageUserID_, UserID_)
SELECT EinzHist.ID AS EinzHistID, EinzHist.EinzTeilID, DATEADD(millisecond, 10, DATEADD(hour, 12, CAST(_IT73650.Abholtag AS datetime2))) AS [DateTime], CAST(2 AS int) AS ActionsID, CAST(2 AS int) AS ZielNrID, CAST(2240 AS int) AS ArbPlatzID, CAST(-1 AS int) AS Menge, _IT73650.LsPoID, _IT73650.Abholtag AS EinAusDat, EinzHist.TraegerID, EinzHist.VsaID, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM EinzHist
JOIN _IT73650 ON EinzHist.Barcode = _IT73650.Barcode AND CAST(_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
WHERE _IT73650.LsPoID IS NOT NULL
  AND EinzHist.EinzHistTyp = 1;

UPDATE EinzHist SET Ausgang1 = _IT73650.Abholtag, Ausgang2 = EinzHist.Ausgang1, Ausgang3 = EinzHist.Ausgang2
FROM _IT73650
WHERE EinzHist.Barcode = _IT73650.Barcode AND CAST(_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  AND EinzHist.EinzHistTyp = 1
  AND _IT73650.LsPoID IS NOT NULL
  AND EinzHist.Ausgang1 < _IT73650.Abholtag;

UPDATE EinzHist SET Ausgang2 = _IT73650.Abholtag, Ausgang3 = EinzHist.Ausgang2
FROM _IT73650
WHERE EinzHist.Barcode = _IT73650.Barcode AND CAST(_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  AND EinzHist.EinzHistTyp = 1
  AND _IT73650.LsPoID IS NOT NULL
  AND EinzHist.Ausgang1 > _IT73650.Abholtag
  AND EinzHist.Ausgang2 < _IT73650.Abholtag;

UPDATE EinzHist SET Ausgang3 = _IT73650.Abholtag
FROM _IT73650
WHERE EinzHist.Barcode = _IT73650.Barcode AND CAST(_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  AND EinzHist.EinzHistTyp = 1
  AND _IT73650.LsPoID IS NOT NULL
  AND EinzHist.Ausgang2 > _IT73650.Abholtag
  AND EinzHist.Ausgang3 < _IT73650.Abholtag;

UPDATE EinzHist SET Eingang1 = E_IT73650.Eingang, Eingang2 = EinzHist.Eingang1, Eingang3 = EinzHist.Eingang2
FROM (
  SELECT Barcode, Abholtag, DATEADD(day, -7, Abholtag) AS Eingang, LsPoID
  FROM _IT73650
) AS E_IT73650
WHERE EinzHist.Barcode = E_IT73650.Barcode AND CAST(E_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  AND EinzHist.EinzHistTyp = 1
  AND E_IT73650.LsPoID IS NOT NULL
  AND EinzHist.Eingang1 < E_IT73650.Eingang;

UPDATE EinzHist SET Eingang2 = E_IT73650.Eingang, Eingang3 = EinzHist.Eingang2
FROM (
  SELECT Barcode, Abholtag, DATEADD(day, -7, Abholtag) AS Eingang, LsPoID
  FROM _IT73650
) AS E_IT73650
WHERE EinzHist.Barcode = E_IT73650.Barcode AND CAST(E_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  AND EinzHist.EinzHistTyp = 1
  AND E_IT73650.LsPoID IS NOT NULL
  AND EinzHist.Eingang1 > E_IT73650.Eingang
  AND EinzHist.Eingang2 < E_IT73650.Eingang;

UPDATE EinzHist SET Eingang3 = E_IT73650.Eingang
FROM (
  SELECT Barcode, Abholtag, DATEADD(day, -7, Abholtag) AS Eingang, LsPoID
  FROM _IT73650
) AS E_IT73650
WHERE EinzHist.Barcode = E_IT73650.Barcode AND CAST(E_IT73650.Abholtag AS datetime2) BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  AND EinzHist.EinzHistTyp = 1
  AND E_IT73650.LsPoID IS NOT NULL
  AND EinzHist.Eingang2 > E_IT73650.Eingang
  AND EinzHist.Eingang3 < E_IT73650.Eingang;