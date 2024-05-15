DECLARE @TraegerNr TABLE (
  KdNr int,
  VsaNr int,
  VsaID int,
  AbteilID int,
  TraegerNr int
);

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO @TraegerNr (KdNr, VsaNr, VsaID, AbteilID, TraegerNr)
SELECT Kunden.KdNr, Vsa.VsaNr, Vsa.ID, Vsa.AbteilID, MAX(Traeger.Traeger) AS TraegerNr
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN _IT82397 ON Kunden.KdNr = _IT82397.Kdnr AND Vsa.VsaNr = _IT82397.VsaNr
GROUP BY Kunden.KdNr, Vsa.VsaNr, Vsa.ID, Vsa.AbteilID;

INSERT INTO Traeger (VsaID, Traeger, AbteilID, PersNr, Vorname, Nachname, Indienst, IndienstDat, AnlageUserID_, UserID_)
SELECT [@TraegerNr].VsaID, [@TraegerNr].TraegerNr + CAST(ROW_NUMBER() OVER (ORDER BY _IT82397.Personalnummer) AS nvarchar), [@TraegerNr].AbteilID, _IT82397.Personalnummer, _IT82397.Vorname, [@TraegerNr].TraegerNr + CAST(ROW_NUMBER() OVER (ORDER BY _IT82397.Personalnummer) AS nvarchar), [Week].Woche, _IT82397.IndienstDat, @userid, @userid
FROM _IT82397
JOIN @TraegerNr ON _IT82397.Kdnr = [@TraegerNr].KdNr AND _IT82397.VsaNr = [@TraegerNr].VsaNr
JOIN [Week] ON _IT82397.IndienstDat BETWEEN [Week].VonDat AND [Week].BisDat;

GO