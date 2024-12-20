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
  UmlaufStatistik.TraeAnz AS [Anzahl Träger historisch],
  UmlaufStatistik.TeilAnz AS [Anzahl Teile historisch]
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
LEFT JOIN (
  SELECT _Umlauf.VsaID, COUNT(DISTINCT _Umlauf.TraegerID) AS TraeAnz, SUM(_Umlauf.Umlauf) AS TeilAnz
  FROM _Umlauf
  JOIN Traeger ON _Umlauf.TraegerID = Traeger.ID
  JOIN Artikel ON _Umlauf.ArtikelID = Artikel.ID
  WHERE _Umlauf.TraegerID > 0
    AND Traeger.Altenheim = 0
    AND Artikel.ArtiTypeID = 1
    AND _Umlauf.Datum = (SELECT [Week].BisDat FROM [Week] WHERE CAST('2024-11-01' AS DATE) BETWEEN [Week].VonDat AND [Week].BisDat)
    AND _Umlauf.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID IN ($2$))
  GROUP BY _Umlauf.VsaID
) AS UmlaufStatistik ON Vsa.ID = UmlaufStatistik.VsaID
WHERE Traeger.Status != N'I'
  AND Traeger.Altenheim = 0
  AND Vsa.Status = N'A'
  AND Kunden.ID IN ($2$)
GROUP BY KdGf.KurzBez, [Zone].ZonenCode, Kunden.KdNr, Kunden.SuchCode, Vsa.ID, Vsa.VsaNr, Vsa.Bez, UmlaufStatistik.TraeAnz, UmlaufStatistik.TeilAnz
ORDER BY KdNr, VsaNr;