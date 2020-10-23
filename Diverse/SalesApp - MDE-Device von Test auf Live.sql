INSERT INTO Wozabal.dbo.MdeDev (Status, Bez, SerienNr, IMEI, eMail, Art, LetzterZugriff, LastMitarbeiID, StatusInfo, Passwort)
SELECT MdeDev.Status, MdeDev.Bez, MdeDev.SerienNr, MdeDev.IMEI, MdeDev.eMail, MdeDev.Art, MdeDev.LetzterZugriff, MdeDev.LastMitarbeiID, MdeDev.StatusInfo, MdeDev.Passwort
FROM [SRVATENADVTEST.WOZABAL.INT\ADVANTEX].Wozabal.dbo.MdeDev
WHERE MdeDev.ID = 4730;