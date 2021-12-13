DECLARE @KdNr int = 10002705;  -- Kundennummer, für die die Auswertung passieren soll

DECLARE @Woche nchar(7) = (SELECT Week.Woche FROM Week WHERE GETDATE() BETWEEN Week.VonDat AND Week.BisDat);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Im WITH werden alle Ausgangs-Scans zu Teilen des Kunden ermittelt (ActionsID 2, 102), und dazu der darauf folgende Wareneingangsscan beim Kunden (ActionID 136) ++ */
/* ++ Sub-Select auf OPTeile des Kunden für deutlich bessere Performance!                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
WITH ScanOut AS (
  SELECT OPScans.OPTeileID, OPScans.Zeitpunkt, MAX(ScanCustomer.Zeitpunkt) AS ScanCustomerZeitpunkt
  FROM OPScans
  LEFT JOIN (
    SELECT OPScans.OPTeileID, OPScans.Zeitpunkt
    FROM OPScans
    WHERE OPScans.ActionsID = 136
      AND OPScans.OPTeileID IN (
        SELECT OPTeile.ID
        FROM OPTeile
        JOIN Vsa ON OPTeile.VsaID = Vsa.ID
        JOIN Kunden ON Vsa.KundenID = Kunden.ID
        WHERE Kunden.KdNr = @KdNr
      )
  ) AS ScanCustomer ON ScanCustomer.OPTeileID = OPScans.OPTeileID AND ScanCustomer.Zeitpunkt > OPScans.Zeitpunkt
  WHERE OPScans.ActionsID IN (2, 102)
    --AND OPScans.LsPoID > 0  -- dann zählen nur noch Auslese-Scans, wo dann auch ein LS generiert wurde; ACHTUNG: migrierte Scans haben nie eine LS-Verweis! daher auskommentiert
    AND OPScans.OpTeileID IN (
      SELECT OPTeile.ID
      FROM OPTeile
      JOIN Vsa ON OPTeile.VsaID = Vsa.ID
      JOIN Kunden ON Vsa.KundenID = Kunden.ID
      WHERE Kunden.KdNr = @KdNr
    )
  GROUP BY OPScans.OPTeileID, OPScans.Zeitpunkt
)
SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kundenstichwort,
  Kunden.Name1 AS [Kunden-Adresszeile 1],
  Vsa.VsaNr AS [VSA-Nr],
  Vsa.Bez AS [VSA-Bezeichnung],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse AS Grö0e,
  OPTeile.Code AS Chipcode,
  CAST(OPTeile.LastScanTime AS date) AS [Letzter Scan],
  OPTeile.Erstwoche,
  fRWOPTeil.BasisAfa AS [Basis-Restwert],
  fRWOPTeil.RestwertInfo AS [Restwert aktuell],
  CAST(fRWOPTeil.RestwertInfo* 100 / IIF(fRWOPTeil.BasisAfa = 0, 1, fRWOPTeil.BasisAfa) AS numeric(5, 2)) AS Prozent,
  DATEDIFF(day, OPTeile.LastScanTime, GETDATE()) AS [Tage seit letztem Scan],
  CAST(OPTeile.LastScanToKunde AS date) AS [Letzter Ausgangs-Scan],
  CAST(ScanOut.ScanCustomerZeitpunkt AS date) AS [Zeitpunkt Wareneingangs-Scan Kunde]
FROM OPTeile
CROSS APPLY funcGetRestwertOP(OPTeile.ID, @Woche, 1) AS fRWOPTeil  -- Aktuellen Restwert je Teil berechnen, für die aktuelle Woche (@Woche-Variable) und die Restwert-Art "Fehlteil"
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
LEFT JOIN ScanOut ON ScanOut.OPTeileID = OPTeile.ID AND ScanOut.Zeitpunkt = OPTeile.LastScanToKunde  -- LEFT JOIN damit wir auch Teile bekommen, wo kein auf den Ausgangs-Scan folgender Wareingangsscan beim Kunden existiert
WHERE Kunden.KdNr = @KdNr
  AND OPTeile.LastActionsID IN (102, 120, 136)
  AND OPTeile.LastScanTime < N'2021-09-14 00:00:00'
  --AND OPTeile.RechPoID = -1 -- nur Teile, die noch verrechnet werden können!
  --AND OPTeile.Code = N'3035307B2831B38300111381'  -- Stichproben; Chipcode hier eintragen
  --AND OPTeile.LastScanTime <= DATEADD(day, -90, GETDATE()) -- Nur Teile, deren letzter Scan mehr als 90 Tage in der Vergangenheit liegt
  AND EXISTS (
    SELECT KdArti.ID
    FROM KdArti
    WHERE KdArti.ArtikelID = ArtGroe.ArtikelID
      AND KdArti.KundenID = Kunden.ID
  );

GO