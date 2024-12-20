/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-89739                                                                                                                  ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2024-12-19                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT KdGf.KurzBez AS Geschäfsbereich,
  [Zone].ZonenCode AS Vertriebszone,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.Bez AS [Vsa-Bezeichnung],
  Vsa.ID AS VsaID,
  Touren = STUFF((SELECT DISTINCT N', ' + Touren.Tour FROM VsaTour JOIN Touren ON VsaTour.TourenID = Touren.ID WHERE VsaTour.VsaID = Vsa.ID AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum FOR XML PATH(N'')), 1, 2, N''),
  COUNT(DISTINCT Traeger.ID) AS [Anzahl Träger],
  SUM(TraeArti.Menge) AS [Anzahl Teile],
  [Anzahl Träger historisch] = (SELECT COUNT(DISTINCT _Umlauf.TraegerID) FROM _Umlauf JOIN Traeger ON _Umlauf.TraegerID = Traeger.ID JOIN Artikel ON _Umlauf.ArtikelID = Artikel.ID WHERE _Umlauf.VsaID = Vsa.ID AND _Umlauf.TraegerID > 0 AND Traeger.Altenheim = 0 AND Artikel.ArtiTypeID = 1 AND _Umlauf.Datum = (SELECT [Week].BisDat FROM [Week] WHERE $3$ BETWEEN [Week].VonDat AND [Week].BisDat)),
  [Anzahl Teile historisch] = (SELECT SUM(_Umlauf.Umlauf) FROM _Umlauf JOIN Traeger ON _Umlauf.TraegerID = Traeger.ID JOIN Artikel ON _Umlauf.ArtikelID = Artikel.ID WHERE _Umlauf.VsaID = Vsa.ID AND _Umlauf.TraegerID > 0 AND Traeger.Altenheim = 0 AND Artikel.ArtiTypeID = 1 AND _Umlauf.Datum = (SELECT [Week].BisDat FROM [Week] WHERE $3$ BETWEEN [Week].VonDat AND [Week].BisDat))
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
WHERE Traeger.Status != N'I'
  AND Traeger.Altenheim = 0
  AND Vsa.Status = N'A'
  AND Kunden.ID IN ($2$)
GROUP BY KdGf.KurzBez, [Zone].ZonenCode, Kunden.KdNr, Kunden.SuchCode, Vsa.ID, Vsa.VsaNr, Vsa.Bez
ORDER BY KdNr, VsaNr;