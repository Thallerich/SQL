DECLARE @customerid int = (SELECT ID FROM Kunden WHERE KdNr = 30686);
DECLARE @targetksstid int = (SELECT Abteil.ID FROM Abteil WHERE Abteil.KundenID = @customerid AND Abteil.Abteilung = N'-');

UPDATE AnfPo SET AbteilID = @targetksstid
WHERE ID IN (
  SELECT AnfPo.ID
  FROM AnfPo
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
  JOIN Vsa ON AnfKo.VsaID = Vsa.ID
  WHERE Vsa.KundenID = @customerid
    AND LsKo.[Status] < N'W'
    AND AnfKo.LieferDatum > N'2023-03-01'
    AND AnfPo.AbteilID != @targetksstid
);

/* UPDATE LsPo SET AbteilID = @targetksstid
WHERE ID IN (
  SELECT LsPo.ID
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  WHERE Vsa.KundenID = @customerid
    AND LsKo.[Status] < N'W'
    AND LsPo.RechPoID < 0
    AND LsPo.AbteilID != @targetksstid
); */

UPDATE MsgTrae SET AbteilID = @targetksstid
WHERE ID IN (
  SELECT MsgTrae.ID
  FROM MsgTrae
  JOIN WebUser ON MsgTrae.WebuserID = WebUser.ID
  WHERE WebUser.KundenID = @customerid
    AND MsgTrae.[Status] < N'U'
    AND MsgTrae.AbteilID != @targetksstid
);

UPDATE MsgVsAnf SET AbteilID = @targetksstid
WHERE ID IN (
  SELECT MsgVsAnf.ID
  FROM MsgVsAnf
  JOIN WebUser ON MsgVsAnf.WebuserID = WebUser.ID
  WHERE WebUser.KundenID = @customerid
    AND MsgVsAnf.[Status] < N'U'
    AND MsgVsAnf.AbteilID != @targetksstid
);

UPDATE Schrank SET AbteilID = @targetksstid
WHERE ID IN (
  SELECT Schrank.ID
  FROM Schrank
  JOIN Vsa ON Schrank.VsaID = Vsa.ID
  WHERE Vsa.KundenID = @customerid
    AND Schrank.AbteilID != @targetksstid
);

UPDATE Traeger SET AbteilID = @targetksstid
WHERE ID IN (
  SELECT Traeger.ID
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  WHERE Vsa.KundenID = @customerid
    AND Traeger.AbteilID != @targetksstid
);

UPDATE Vsa SET AbteilID = @targetksstid
WHERE ID IN (
  SELECT Vsa.ID
  FROM Vsa
  WHERE Vsa.KundenID = @customerid
    AND Vsa.AbteilID != @targetksstid
);
  
UPDATE VsaAnf SET AbteilID = @targetksstid
WHERE ID IN (
  SELECT VsaAnf.ID
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  WHERE Vsa.KundenID = @customerid
    AND VsaAnf.AbteilID != @targetksstid
);

UPDATE VsaLeas SET AbteilID = @targetksstid
WHERE ID IN (
  SELECT VsaLeas.ID
  FROM VsaLeas
  JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
  WHERE Vsa.KundenID = @customerid
    AND FORMAT(DATEPART(year, GETDATE()), N'0000') + N'/' + FORMAT(DATEPART(week, GETDATE()), N'00') BETWEEN Vsaleas.InDienst AND ISNULL(VsaLeas.AusDienst, N'2099/52')
    AND VsaLeas.AbteilID != @targetksstid
);

GO

/* Wochenabschlüsse der noch nicht fakturierten Wochen wiederholen! */