/* ALTER TABLE _BMMitarbei2 ADD BereichID int, BetreuerID int, VertriebID int, KundenserviceID int;
GO

UPDATE _BMMitarbei2 SET BereichID = -1, BetreuerID = -1, VertriebID = -1, KundenserviceID = -1;

GO

UPDATE _BMMitarbei2 SET BereichID = Bereich.ID
FROM Bereich
WHERE _BMMitarbei2.Bereich COLLATE Latin1_General_CS_AS = Bereich.BereichBez;

GO

UPDATE _BMMitarbei2 SET BetreuerID = Mitarbei.ID
FROM Mitarbei
WHERE _BMMitarbei2.Betreuer COLLATE Latin1_General_CS_AS = Mitarbei.MaNr;

GO

UPDATE _BMMitarbei2 SET VertriebID = Mitarbei.ID
FROM Mitarbei
WHERE _BMMitarbei2.Vertrieb COLLATE Latin1_General_CS_AS = Mitarbei.MaNr;

GO

UPDATE _BMMitarbei2 SET KundenserviceID = Mitarbei.ID
FROM Mitarbei
WHERE _BMMitarbei2.Kundenservice COLLATE Latin1_General_CS_AS = Mitarbei.MaNr;

GO */

WITH MaImport AS (
  SELECT DISTINCT KdNr, BereichID, BetreuerID, VertriebID, KundenserviceID
  FROM _BMMitarbei2
)
UPDATE VsaBer SET BetreuerID = MaImport.BetreuerID, VertreterID = MaImport.VertriebID, ServiceID = MaImport.KundenserviceID
FROM VsaBer
JOIN Vsa ON VsaBer.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN MaImport ON MaImport.KdNr = Kunden.KdNr AND MaImport.BereichID = KdBer.BereichID;

GO

WITH MaImport AS (
  SELECT DISTINCT KdNr, BereichID, BetreuerID, VertriebID, KundenserviceID
  FROM _BMMitarbei2
)
UPDATE KdBer SET BetreuerID = MaImport.BetreuerID, VertreterID = MaImport.VertriebID, ServiceID = MaImport.KundenserviceID
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN MaImport ON MaImport.KdNr = Kunden.KdNr AND MaImport.BereichID = KdBer.BereichID;

GO