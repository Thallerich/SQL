DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @oldfaklaufid int = 70124;
DECLARE @newfaklaufid int;

DECLARE @FakLauf TABLE (
  FakLaufID int
);

INSERT INTO FakLauf ([Status], Bez, Datum, Monat, BenutzerID, StartZeit, StopZeit, Notizen, Leasing, EffektivBis, Restwerte, RestwerteGS, Verkauf, RechZuFaAbrechnenBis, Applikationen, AnlageUserID_, UserID_)
OUTPUT inserted.ID INTO @FakLauf (FakLaufID)
SELECT [Status], N'Abschluss rückgängig SMRS', Datum, Monat, @userid, GETDATE(), GETDATE(), N'IT-84601', Leasing, EffektivBis, Restwerte, RestwerteGS, Verkauf, RechZuFaAbrechnenBis, Applikationen, @userid, @userid
FROM FakLauf
WHERE ID = 70124;

SET @newfaklaufid = (SELECT TOP 1 FakLaufID FROM @FakLauf);

SELECT RechKo.ID AS RechKoID, RechKo.RechNr, RechKo.ExtRechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE EXISTS (
    SELECT RechPo.*
    FROM RechPo
    WHERE RechPo.RechKoID = RechKo.ID
      AND RechPo.FakLaufID = 70124
  )
  AND RechKo.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'SMRS');

UPDATE RechPo SET FakLaufID = @newfaklaufid
WHERE RechPo.FakLaufID = @oldfaklaufid
  AND RechPo.RechKoID IN (
    SELECT RechKo.ID AS RechKoID
    FROM RechKo
    JOIN Kunden ON RechKo.KundenID = Kunden.ID
    WHERE EXISTS (
        SELECT RechPo.*
        FROM RechPo
        WHERE RechPo.RechKoID = RechKo.ID
          AND RechPo.FakLaufID = 70124
      )
      AND RechKo.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'SMRS')
  );

GO