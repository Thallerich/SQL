/*
StandKonID 6 - BK: Lenzing1
StandKonID 1 - BK: Enns
StandKonID 5 - BK: Lenzing2
*/
/*
SELECT Vsa.ID AS VsaID, Vsa.StandKonID, Kunden.KdNr, Vsa.SuchCode AS VsaSuchCode, Vsa.Bez AS VsaBez, Vsa.Status
INTO ___VsaStandKonID_Backup_20181121
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr IN (24045, 18027)
  AND Vsa.StandKonID = 6
  AND Vsa.Status = N'A';

UPDATE Vsa SET StandKonID = 1 WHERE ID IN (SELECT vsaID FROM ___VsaStandKonID_Backup_20181121);
*/
update vsa set suchcode = suchcode Where ID in (Select VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027);
update vsaber set Status = Status Where VSAID in (Select VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027);
update vsatexte set vsaid = vsaid Where VSAID in (Select VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027);
update vsatour set vsaid = vsaid Where VSAID in (Select VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027);
update traeger set Status = Status Where VSAID in (Select VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027);
update traearti set vsaid = vsaid Where VSAID in (Select VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027);
update teile set vsaid = vsaid Where VSAID in (Select VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027);
update schrank set vsaid = vsaid Where VSAID in (Select VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027);
update Hinweis set aktiv = aktiv Where TeileID in (SELECT ID FROm Teile WHERE VSAID IN (SELECT VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027)) AND aktiv = 1;
--update teilerep set id = id Where TeileID in (SELECT ID FROm Teile WHERE VSAID IN (SELECT VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027));
update teilmass set TeileID = TeileID Where TeileID in (SELECT ID FROm Teile WHERE VSAID IN (SELECT VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027));
update traefach set Fach = Fach Where SchrankID in (SELECT ID FROM SCHRANK WHERE VsaID in (Select VSAID FROM ___VsaStandKonID_Backup_20181121 WHERE KdNr = 18027));