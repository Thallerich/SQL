DECLARE @filter datetime = CAST(CAST($1$ AS nchar(10))+ N' 00:00:00' AS datetime);

SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(EinzTeil.ID) AS AnzahlTeile
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
WHERE Kunden.ID = $ID$
  AND DATEDIFF(day, EinzTeil.LastScanToKunde, GETDATE()) > 90
  AND ((EinzTeil.[Status] = N'Q' AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154, 165, 173)) OR (EinzTeil.[Status] = N'W' AND NOT EXISTS (SELECT TeilSoFa.* FROM TeilSoFa WHERE TeilSoFa.EinzTeilID = EinzTeil.ID AND TeilSoFa.SoFaArt = 'R')))  /* bei Schwund-Teilen nur nicht verrechnete und nicht für Verrechnung gesperrte Teile */
  AND Artikel.EAN IS NOT NULL
  AND LEN(EinzTeil.Code) = 24
  AND Artikel.BereichID != 104
  AND EinzTeil.LastScanToKunde > @filter
  AND EinzHist.PoolFkt = 1
GROUP BY Kunden.ID, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Kunden.KdNr, Vsa.VsaNr, Artikelbezeichnung;