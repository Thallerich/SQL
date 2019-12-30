DECLARE @Woche nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], VsaPause.VonDatum, VsaPause.VonWoche, VsaPause.BisDatum, VsaPause.BisWoche, VsaPause.IsLieferpause, VsaPause.LeasRabatt, VsaPause.UseSonderpreis, Mitarbei.UserName AS [Anlage-User], VsaPause.Anlage_ AS [Anlage-Zeitpunkt]
FROM VsaPause
JOIN Vsa ON VsaPause.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Mitarbei ON VsaPause.AnlageUserID_ = Mitarbei.ID
WHERE (
  (CAST(GETDATE() AS date) BETWEEN VsaPause.VonDatum AND VsaPause.BisDatum AND VsaPause.VonDatum IS NOT NULL)
  OR
  (@Woche BETWEEN VsaPause.VonWoche AND VsaPause.BisWoche AND VsaPause.VonWoche IS NOT NULL)
)
AND VsaPause.IsLieferpause = 0
AND VsaPause.LeasRabatt = 0
AND VsaPause.UseSonderpreis = 0;