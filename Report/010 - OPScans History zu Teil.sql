DECLARE @Code nvarchar(33) = $1$;

IF (@Code = N'' OR @Code IS NULL)
BEGIN
  SELECT N'Kein Barcode / Chipcode eingegeben!';
END
ELSE
BEGIN
  SELECT OPScans.Code, OPScans.Zeitpunkt, ZielNr.ZielNrBez$LAN$ AS ZielNr, WegGrund.WegGrundBez$LAN$ AS Grund, MitarbeiUser AS [User], ISNULL(AnfKoIn.AuftragsNr, AnfKoOut.AuftragsNr) AS Packzettel, ISNULL(AnfKoIn.Lieferdatum, AnfKoOut.Lieferdatum) AS [PZ-Lieferdatum], ISNULL(AnfPoIn.AnfKoID, AnfPoOut.AnfKoID) AS AnfKoID
  FROM WegGrund, ZielNr, (
    SELECT EinzTeil.Code, Scans.[DateTime] AS Zeitpunkt, Scans.ZielNrID, Scans.AnfPoID, Scans.EingAnfPoID, Scans.GrundID, Mitarbei.MitarbeiUser
    FROM Scans, EinzTeil, Mitarbei
    WHERE Scans.EinzTeilID = EinzTeil.ID
      AND Scans.AnlageUserID_ = Mitarbei.ID
      AND (
        EinzTeil.Code = @Code OR EinzTeil.Code2 = @Code
      )
    ) AS OPScans
  LEFT JOIN AnfPo AnfPoOut ON AnfPoOut.ID = opscans.AnfPoID AND opScans.AnfPoID > 0
  LEFT JOIN AnfKo AnfKoOut ON AnfKoOut.ID = AnfPoOut.AnfKoID
  LEFT JOIN AnfPo AnfPoIn ON AnfPoIn.ID = opScans.EingAnfPoID AND opScans.EingAnfPoID > 0
  LEFT JOIN AnfKo AnfKoIn ON AnfKoIn.ID = AnfPoIn.AnfKoID
  WHERE opScans.ZielNrID = ZielNr.ID
    AND opScans.GrundID = WegGrund.ID
  ORDER BY opscans.Code, opscans.Zeitpunkt DESC;
END;