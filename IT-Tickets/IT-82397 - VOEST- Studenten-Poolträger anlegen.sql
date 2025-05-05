DECLARE @MaxTNrPerCustomer TABLE (
  KdNr int,
  MaxTraegerNr int
);

DECLARE @TraegerNr TABLE (
  KdNr int,
  VsaNr int,
  VsaID int,
  AbteilID int,
  TraegerNr int
);

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @indienstdat date = N'2025-06-01';
DECLARE @indienstwoche nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE @indienstdat BETWEEN [Week].VonDat AND [Week].BisDat);

INSERT INTO @MaxTNrPerCustomer (KdNr, MaxTraegerNr)
SELECT Kunden.KdNr, MAX(Traeger.Traeger)
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr IN (
  SELECT [_VOESTStudentenImport].KdNr
  FROM [_VOESTStudentenImport]
)
GROUP BY Kunden.KdNr;

INSERT INTO Traeger (VsaID, Traeger, AbteilID, PersNr, Vorname, Nachname, Indienst, IndienstDat, AnlageUserID_, UserID_)
SELECT
  VsaID = Vsa.ID,
  Traeger = [@MaxTNrPerCustomer].MaxTraegerNr + CAST(ROW_NUMBER() OVER (ORDER BY [_VOESTStudentenImport].PersNr) AS nvarchar),
  AbteilID = COALESCE((SELECT TOP 1 Abteil.ID FROM Abteil WHERE Abteil.KundenID = Kunden.ID AND Abteil.Bez = [_VOESTStudentenImport].Kostenstelle), Vsa.AbteilID),
  PersNr = [_VOESTStudentenImport].PersNr,
  Vorname = [_VOESTStudentenImport].Vorname,
  Nachname = [_VOESTStudentenImport].Nachname,
  Indienst = @indienstwoche,
  IndienstDat = @indienstdat,
  AnlageUserID_ = @userid,
  UserID_ = @userid
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN [_VOESTStudentenImport] ON Kunden.KdNr = [_VOESTStudentenImport].Kdnr AND Vsa.VsaNr = [_VOESTStudentenImport].VsaNr
JOIN @MaxTNrPerCustomer ON [@MaxTNrPerCustomer].KdNr = [_VOESTStudentenImport].KdNr;

GO