DECLARE @MASwitch TABLE (
  MitarbeiID_Alt int,
  MitarbeiID_Neu int
);

INSERT INTO @MASwitch
SELECT Mitarbei.ID AS MitarbeiID_Alt, (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.Name = N'Tiric, Nihad') AS MitarbeiID_Neu
FROM Mitarbei
WHERE Mitarbei.Name IN (N'Pirker, Stefan', N'Leitner, Roman');

UPDATE KdBer SET KdBer.ServiceID = MASwitch.MitarbeiID_Neu
FROM KdBer
JOIN @MASwitch AS MASwitch ON MASwitch.MitarbeiID_Alt = KdBer.ServiceID;

UPDATE KdBer SET KdBer.BetreuerID = MASwitch.MitarbeiID_Neu
FROM KdBer
JOIN @MASwitch AS MASwitch ON MASwitch.MitarbeiID_Alt = KdBer.BetreuerID;

UPDATE KdBer SET KdBer.VertreterID = MASwitch.MitarbeiID_Neu
FROM KdBer
JOIN @MASwitch AS MASwitch ON MASwitch.MitarbeiID_Alt = KdBer.VertreterID;

UPDATE VsaBer SET VsaBer.ServiceID = MASwitch.MitarbeiID_Neu
FROM VsaBer
JOIN @MASwitch AS MASwitch ON MASwitch.MitarbeiID_Alt = VsaBer.ServiceID;

UPDATE VsaBer SET VsaBer.BetreuerID = MASwitch.MitarbeiID_Neu
FROM VsaBer
JOIN @MASwitch AS MASwitch ON MASwitch.MitarbeiID_Alt = VsaBer.BetreuerID;

UPDATE VsaBer SET VsaBer.VertreterID = MASwitch.MitarbeiID_Neu
FROM VsaBer
JOIN @MASwitch AS MASwitch ON MASwitch.MitarbeiID_Alt = VsaBer.VertreterID;