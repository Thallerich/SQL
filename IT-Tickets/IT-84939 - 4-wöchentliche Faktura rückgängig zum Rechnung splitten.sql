DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @oldfaklauf1id int = 70506;
DECLARE @newfaklauf1id int;

DECLARE @oldfaklauf2id int = 70508;
DECLARE @newfaklauf2id int;

DECLARE @FakLaufMap TABLE (
  FakLaufID int,
  NewFakLaufID int
);

DECLARE @RechKo TABLE (
  RechNr int
);

INSERT INTO @RechKo
VALUES (-11720826), (-11720808);

INSERT INTO FakLauf ([Status], Bez, Datum, Monat, BenutzerID, StartZeit, StopZeit, Notizen, Leasing, EffektivBis, Restwerte, RestwerteGS, Verkauf, RechZuFaAbrechnenBis, Applikationen, AnlageUserID_, UserID_)
OUTPUT inserted.ID INTO @FakLaufMap (NewFakLaufID)
SELECT [Status], N'Rechnung splitten', Datum, Monat, @userid, GETDATE(), GETDATE(), N'IT-84939', Leasing, EffektivBis, Restwerte, RestwerteGS, Verkauf, RechZuFaAbrechnenBis, Applikationen, @userid, @userid
FROM FakLauf
WHERE ID = @oldfaklauf1id;

UPDATE @FakLaufMap SET FakLaufID = @oldfaklauf1id WHERE FakLaufID IS NULL;

INSERT INTO FakLauf ([Status], Bez, Datum, Monat, BenutzerID, StartZeit, StopZeit, Notizen, Leasing, EffektivBis, Restwerte, RestwerteGS, Verkauf, RechZuFaAbrechnenBis, Applikationen, AnlageUserID_, UserID_)
OUTPUT inserted.ID INTO @FakLaufMap (NewFakLaufID)
SELECT [Status], N'Rechnung splitten', Datum, Monat, @userid, GETDATE(), GETDATE(), N'IT-84939', Leasing, EffektivBis, Restwerte, RestwerteGS, Verkauf, RechZuFaAbrechnenBis, Applikationen, @userid, @userid
FROM FakLauf
WHERE ID = @oldfaklauf2id;

UPDATE @FakLaufMap SET FakLaufID = @oldfaklauf2id WHERE FakLaufID IS NULL;

SET @newfaklauf1id = (SELECT TOP 1 NewFakLaufID FROM @FakLaufMap WHERE FakLaufID = @oldfaklauf1id);
SET @newfaklauf2id = (SELECT TOP 1 NewFakLaufID FROM @FakLaufMap WHERE FakLaufID = @oldfaklauf2id);

UPDATE RechPo SET FakLaufID = [@FakLaufMap].NewFakLaufID
FROM @FakLaufMap
WHERE RechPo.FakLaufID = [@FakLaufMap].FakLaufID
  AND RechPo.RechKoID IN (SELECT RechKo.ID FROM RechKo WHERE RechKo.RechNr IN (SELECT RechNr FROM @RechKo));