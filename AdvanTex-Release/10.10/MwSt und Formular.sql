UPDATE MwStZeit SET MwStSatz = 0, MwStFaktor = 0 WHERE MwStID = -1;

UPDATE Formular SET ParamStr = ParamStr + N';BezahlCode=0' WHERE Typ = 'RECHKO' AND ParamStr NOT LIKE N'%BezahlCode=%';
UPDATE Forumlar SET ParamStr = 'ShowLsNr=1;LsNrPos=Abteil;ShowPreise=1;SwapHeader=1;ShowBewLsNr=1;EPCQRCode=0;BezahlCode=0' WHERE ID = 55;

UPDATE RptRepor SET RandOben = 8, RandObenSeite2 = 8, RandUnten = 3, RandLinks = 6.3, RandRechts = 6.3 WHERE ID = 20262;