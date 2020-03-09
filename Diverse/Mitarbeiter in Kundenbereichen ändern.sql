DECLARE @MASwitch TABLE (
  MitarbeiID_Alt int,
  MitarbeiID_Neu int
);

INSERT INTO @MASwitch
SELECT 9013900 AS MitarbeiID_Alt, 9014305 AS MitarbeiID_Neu;

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