DECLARE @Woche nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @Datum date = CAST(GETDATE() AS date);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], VsaPause.VonDatum, VsaPause.VonWoche, VsaPause.BisDatum, VsaPause.BisWoche, VsaPause.IsLieferpause, VsaPause.LeasRabatt, VsaPause.UseSonderpreis, Mitarbei.UserName AS [Anlage-User], VsaPause.Anlage_ AS [Anlage-Zeitpunkt], Mitarbei.Name
FROM VsaPause
JOIN Vsa ON VsaPause.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Mitarbei ON VsaPause.AnlageUserID_ = Mitarbei.ID
WHERE (
  (VsaPause.BisDatum > @Datum AND VsaPause.VonDatum IS NOT NULL)
  OR
  (VsaPause.BisWoche > @Woche AND VsaPause.VonWoche IS NOT NULL)
)
AND VsaPause.IsLieferpause = 0
AND VsaPause.LeasRabatt = 0
AND VsaPause.UseSonderpreis = 0;