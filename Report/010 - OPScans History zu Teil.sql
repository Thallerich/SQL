DECLARE @Code char(33);

SET @Code = $1$;

SELECT OPScans.Code, OPScans.Zeitpunkt, ZielNr.ZielNrBez$LAN$ AS ZielNr, WegGrund.WegGrundBez$LAN$ AS Grund, MitarbeiUser AS [User], ISNULL(AnfKoIn.AuftragsNr, AnfKoOut.AuftragsNr) AS Packzettel, ISNULL(AnfKoIn.Lieferdatum, AnfKoOut.Lieferdatum) AS [PZ-Lieferdatum], ISNULL(AnfPoIn.AnfKoID, AnfPoOut.AnfKoID) AS AnfKoID
FROM WegGrund, ZielNr, (
  SELECT OPTeile.Code, OPScans.Zeitpunkt, OPScans.ZielNrID, OPScans.AnfPoID, OPScans.EingAnfPoID, OPScans.OPGrundID, Mitarbei.MitarbeiUser
  FROM OPScans, OPTeile, Mitarbei
  WHERE OPScans.OPTeileID = OPTeile.ID
    AND OPScans.AnlageUserID_ = Mitarbei.ID
    AND (
      OPTeile.Code = @Code OR OPTeile.Code2 = @Code
    )
  
  UNION ALL
  
  SELECT OPTeile.Code, OPScans.Zeitpunkt, OPScans.ZielNrID, OPScans.AnfPoID, OPScans.EingAnfPoID, OPScans.OPGrundID, OPScans.AnlageUser_ COLLATE Latin1_General_CS_AS AS MitarbeiUser
  FROM Wozabal_Archive.dbo.OPScans, Wozabal.dbo.OPTeile
  WHERE OPScans.OPTeileID = OPTeile.ID
    AND (
      OPTeile.Code = @Code OR OPTeile.Code2 = @Code
    )
  ) AS OPScans
LEFT OUTER JOIN AnfPo AnfPoOut ON AnfPoOut.ID = OPScans.AnfPoID AND OPScans.AnfPoID > 0
LEFT OUTER JOIN AnfKo AnfKoOut ON AnfKoOut.ID = AnfPoOut.AnfKoID
LEFT OUTER JOIN AnfPo AnfPoIn ON AnfPoIn.ID = OPScans.EingAnfPoID AND OPScans.EingAnfPoID > 0
LEFT OUTER JOIN AnfKo AnfKoIn ON AnfKoIn.ID = AnfPoIn.AnfKoID
WHERE OPScans.ZielNrID = ZielNr.ID
  AND OPScans.OPGrundID = WegGrund.ID
ORDER BY OPScans.Code, OPScans.Zeitpunkt DESC;