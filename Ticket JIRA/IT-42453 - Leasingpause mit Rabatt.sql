DECLARE @CurrentWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunden, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, COALESCE(CAST(VsaPause.VonDatum AS nvarchar(10)), CAST(VsaPause.VonWoche AS nvarchar(10))) AS [Pause von], COALESCE(CAST(VsaPause.BisDatum AS nvarchar(10)), CAST(VsaPause.BisWoche AS nvarchar(10))) AS [Pause bis], VsaPause.IsLieferpause AS [Ist Lieferpause?], VsaPause.LeasRabatt AS Leasingrabatt
FROM VsaPause
JOIN Vsa ON VsaPause.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE VsaPause.LeasRabatt != 0
  AND VsaPause.IsTraegerPause = 0
  AND VsaPause.TraegerID < 0
  AND (CAST(GETDATE() AS date) BETWEEN VsaPause.VonDatum AND VsaPause.BisDatum OR @CurrentWeek BETWEEN VsaPause.VonWoche AND VsaPause.BisWoche);