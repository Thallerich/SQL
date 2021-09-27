CREATE OR ALTER VIEW sapbw.V_BW_ADV_OPSCANSUHF AS
SELECT OPTeile.ID AS Chipcode, --(Code wird als Textfeld gesondert geladen... - WTF?)
  ArtikelNr = UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)),
  Auslesezeitpunkt = Poolscan.Zeitpunkt,
  Auslesedatum = CAST(Poolscan.Zeitpunkt AS date),
  Einlesezeitpunkt = Poolscan.NextZeitpunkt,
  Einlesedatum = CAST(Poolscan.NextZeitpunkt AS date),
  Vsa.VsaNr,
  Kunden.KdNr
FROM Salesianer.dbo.OPTeile
JOIN Salesianer.dbo.ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN Salesianer.dbo.Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN (
  SELECT OPScans.OPTeileID, OPScans.Zeitpunkt, LEAD(OPScans.Zeitpunkt) OVER (PARTITION BY OPScans.OPTeileID ORDER BY OPScans.Zeitpunkt) AS NextZeitpunkt, OPScans.AnfPoID, AnfKo.VsaID
  FROM Salesianer.dbo.OPScans
  JOIN Salesianer.dbo.AnfPo ON OPScans.AnfPoID = AnfPo.ID
  JOIN Salesianer.dbo.AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  WHERE OPScans.Menge != 0
    AND OPScans.ActionsID IN (1, 100, 2, 102)
    AND OPScans.Zeitpunkt >= N'2019-01-01 00:00:00'
) AS Poolscan ON Poolscan.OPTeileID = OPTeile.ID
JOIN Salesianer.dbo.Vsa ON Poolscan.VsaID = Vsa.ID
JOIN Salesianer.dbo.Kunden ON Vsa.KundenID = Kunden.ID
WHERE Poolscan.AnfPoID > 0;

GO