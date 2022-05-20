WITH MaImport AS (
  SELECT KdNr, VsaNr, BereichID, BetreuerID, VertriebID, KundenserviceID
  FROM _BMMitarbei
)
UPDATE VsaBer SET BetreuerID = MaImport.BetreuerID, VertreterID = MaImport.VertriebID, ServiceID = MaImport.KundenserviceID
FROM VsaBer
JOIN Vsa ON VsaBer.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN MaImport ON MaImport.KdNr = Kunden.KdNr AND MaImport.VsaNr = Vsa.VsaNr AND MaImport.BereichID = KdBer.BereichID;

GO

WITH MaImport AS (
  SELECT DISTINCT KdNr, BereichID, BetreuerID, VertriebID, KundenserviceID
  FROM _BMMitarbei
)
UPDATE KdBer SET BetreuerID = MaImport.BetreuerID, VertreterID = MaImport.VertriebID, ServiceID = MaImport.KundenserviceID
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN MaImport ON MaImport.KdNr = Kunden.KdNr AND MaImport.BereichID = KdBer.BereichID;

GO