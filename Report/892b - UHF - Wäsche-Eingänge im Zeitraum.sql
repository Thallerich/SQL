DECLARE @KundenID int = $ID$;
DECLARE @EingelesenVon datetime = CAST($1$ AS datetime);
DECLARE @EingelesenBis datetime = CAST(DATEADD(day, 1, $2$) AS datetime);

WITH Eingangsscans AS (
  SELECT MAX(OPScans.ID) AS OPScansID_Out, OPScans.OPTeileID, Eingangsscans.OPScansID AS OPScansID_In
  FROM OPScans
  JOIN (
    SELECT OPScans.ID AS OPScansID, OPScans.OPTeileID, OPScans.Zeitpunkt
    FROM OPScans
    WHERE OPScans.Zeitpunkt BETWEEN @EingelesenVon AND @EingelesenBis
      AND OPScans.Menge = 1
  ) AS Eingangsscans ON OPScans.OPTeileID = Eingangsscans.OPTeileID AND OPScans.Zeitpunkt < Eingangsscans.Zeitpunkt
  WHERE OPScans.Menge = -1
  GROUP BY OPScans.OPTeileID, Eingangsscans.OPScansID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, OPScans_In.Zeitpunkt AS [Einlesezeitpunkt], ZielNr.ZielNrBez AS [Einlese-Ort], LsKo.LsNr AS [geliefert mit LsNr], LsKo.Datum AS [geliefert am], OPTeile.Code AS Chipcode, CAST(IIF(OPTeile.VsaOwnerID > 0, 1, 0) AS bit) AS [Eigenwäsche?]
FROM Eingangsscans
JOIN OPTeile ON Eingangsscans.OPTeileID = OPTeile.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN OPScans AS OPScans_Out ON Eingangsscans.OPScansID_Out = OPScans_Out.ID
JOIN OPScans AS OPScans_In ON Eingangsscans.OPScansID_In = OPScans_In.ID
JOIN ZielNr ON OPScans_In.ZielNrID = ZielNr.ID
JOIN AnfPo ON OPScans_Out.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.ID = @KundenID
  AND (($3$ = 1 AND OPTeile.VsaOwnerID > 0) OR ($3$ = 0));