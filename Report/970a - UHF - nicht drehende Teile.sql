DECLARE @RwArt integer = 1;
DECLARE @Woche nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @filter datetime = CAST(CAST($1$ AS nchar(10))+ N' 00:00:00' AS datetime);

SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, EinzTeil.Code, EinzTeil.Code2, EinzTeil.LastScanToKunde AS [letzter Ausgangsscan], EinzTeil.Erstwoche, OPRW.RestwertInfo AS Restwert
FROM EinzTeil
CROSS APPLY dbo.funcGetRestwertOP(EinzTeil.ID, @Woche, @RwArt) AS OPRW
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
WHERE Kunden.ID = $ID$
  AND DATEDIFF(day, EinzTeil.LastScanToKunde, GETDATE()) > 90
  AND ((EinzTeil.[Status] = N'Q' AND EinzTeil.LastActionsID = 102) OR (EinzTeil.[Status] = N'W' AND EinzTeil.RechPoID = -1))  /* bei Schwund-Teilen nur nicht verrechnete und nicht für Verrechnung gesperrte Teile */
  AND Artikel.EAN IS NOT NULL
  AND LEN(EinzTeil.Code) = 24
  AND Artikel.BereichID != 104
  AND EinzTeil.LastScanToKunde > @filter
  AND EinzHist.PoolFkt = 1
ORDER BY Kunden.KdNr, Vsa.VsaNr, Artikel.ArtikelNr;