SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Abteil.Abteilung AS KsSt,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Vsa.Suchcode AS VsaNr,
  Vsa.Bez AS Vsa,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) AS [Anzahl Tage beim Kunden],
  FORMAT(OPTeile.LastScanToKunde, 'G', 'de-AT') AS [Letzter Ausgangsscan zum Kunden],
  (
    SELECT ISNULL(FORMAT(CAST(MAX(OPScans.Zeitpunkt) AS date), 'd', 'de-AT'), '')
    FROM OPScans
    WHERE OPScans.OPTeileID = OPTeile.ID
      AND OPScans.Zeitpunkt > OPTeile.LastScanToKunde
      AND OPScans.ZielNrID = 10000104 -- Inventur beim Kunden
  ) AS Inventurdatum,
  OPTeile.Code AS Chipcode,
  CASE
    WHEN OPTeile.Status = N'W' THEN N'Schwund'
    WHEN OPTeile.Status = N'Q' AND Actions.ID = 102 THEN N'Ausgelesen'
    ELSE N'unbekannt'
  END AS [Status des Teils],
  OPTeile.AnzWasch AS [Anzahl Wäschen],
  OPTeile.AlterInfo AS [Alter des Teils in Wochen],
  CAST(OPTeile.EkGrundAkt * 1.3 AS money) AS Preis,
  CAST(OPTeile.AusDRestwert AS money) AS Restwert
FROM OPTeile
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Status ON OPTeile.Status = Status.Status AND Status.Tabelle = N'OPTEILE'
JOIN Actions ON OPTeile.LastActionsID = Actions.ID
WHERE Holding.Holding = N'LPH NÖ'
  --AND (OPTeile.Status = N'W' OR (OPTeile.Status = N'Q' AND OPTeile.LastActionsID = 102)) -- 102 = OP Auslesen
  AND OPTeile.RechPoID IN (
    SELECT RechPo.ID
    FROM RechPo
    JOIN RechKo ON RechPo.RechKoID = RechKo.ID
    JOIN RKoType ON RechKo.RKoTypeID = RKoType.ID
    WHERE RechKo.KundenID = Kunden.ID
      AND RKoType.Bez = N'Schwundverrechnung UHF-Pool'
  )
ORDER BY Kunden.KdNr, Abteil.Abteilung, Artikel.ArtikelNr;