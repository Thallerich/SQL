DECLARE @von datetime;
DECLARE @bis datetime;

SET @von = $1$;
SET @bis = $2$;

DROP TABLE IF EXISTS #TmpSchwund;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Status.Bez AS VsaStatus, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Bereich.BereichBez$LAN$ AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 0 AS Vertragsbestand, 0 AS SchwundZeitraum, 0 AS SchwundAlt, 0 AS BereitsSchwundmarkiertZeitraum, 0 AS BereitsSchwundmarkiertAlt, 0 AS BereitsSchwundmarkiertNeu, 0 AS SchwundGesperrt, 0 AS Durchschnittsliefermenge, Artikel.EKPreis, Vsa.ID AS VsaID, Artikel.ID AS ArtikelID
INTO #TmpSchwund
FROM OPTeile, Vsa, Kunden, Artikel, Bereich, (SELECT Status.Status, Status.StatusBez$LAN$ AS Bez FROM Status WHERE Status.Tabelle = 'VSA') AS Status
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Vsa.Status = Status.Status
  AND Kunden.ID = $ID$
  AND Artikel.EAN IS NOT NULL
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Status.Bez, Vsa.SuchCode, Vsa.Bez, Bereich.BereichBez$LAN$, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Artikel.EKPreis, Vsa.ID, Artikel.ID;

UPDATE Schwund SET Schwund.Vertragsbestand = x.Bestand, Schwund.Durchschnittsliefermenge = x.Durchschnitt
FROM #TmpSchwund AS Schwund, (
  SELECT VsaAnf.Bestand, VsaAnf.Durchschnitt, VsaAnf.VsaID, KdArti.ArtikelID
  FROM VsaAnf, KdArti
  WHERE VsaAnf.KdArtiID = KdArti.ID
    AND VsaAnf.VsaID IN (SELECT VsaID FROM #TmpSchwund)
) AS x
WHERE x.VsaID = Schwund.VsaID
  AND x.ArtikelID = Schwund.ArtikelID;

UPDATE Schwund SET Schwund.SchwundZeitraum = x.Anzahl
FROM #TmpSchwund AS Schwund, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anzahl
  FROM OPTeile
  WHERE OPTeile.VsaID IN (SELECT VsaID FROM #TmpSchwund)
    AND OPTeile.LastScanTime BETWEEN @von AND @bis
    AND OPTeile.Status IN (N'A', N'Q')
    AND OPTeile.LastActionsID = 102  -- Teile beim Kunden
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) AS x
WHERE x.VsaID = Schwund.VsaID
  AND x.ArtikelID = Schwund.ArtikelID;

UPDATE Schwund SET Schwund.SchwundAlt = x.Anzahl
FROM #TmpSchwund AS Schwund, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anzahl
  FROM OPTeile
  WHERE OPTeile.VsaID IN (SELECT VsaID FROM #TmpSchwund)
    AND OPTeile.LastScanTime < @von
    AND OPTeile.Status IN (N'A', N'Q')
    AND OPTeile.LastActionsID = 102  -- Teile beim Kunden
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) AS x
WHERE x.VsaID = Schwund.VsaID
  AND x.ArtikelID = Schwund.ArtikelID;

UPDATE Schwund SET Schwund.BereitsSchwundmarkiertZeitraum = x.Anzahl
FROM #TmpSchwund AS Schwund, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anzahl
  FROM OPTeile
  WHERE OPTeile.VsaID IN (SELECT VsaID FROM #TmpSchwund)
    AND OPTeile.Status = 'W'
    AND OPTeile.RechPoID = -1
    AND OPTeile.LastScanTime BETWEEN @von AND @bis
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) AS x
WHERE x.VsaID = Schwund.VsaID
  AND x.ArtikelID = Schwund.ArtikelID;

UPDATE Schwund SET Schwund.BereitsSchwundmarkiertAlt = x.Anzahl
FROM #TmpSchwund AS Schwund, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anzahl
  FROM OPTeile
  WHERE OPTeile.VsaID IN (SELECT VsaID FROM #TmpSchwund)
    AND OPTeile.Status = 'W'
    AND OPTeile.RechPoID = -1
    AND OPTeile.LastScanTime < @von
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) AS x
WHERE x.VsaID = Schwund.VsaID
  AND x.ArtikelID = Schwund.ArtikelID;

UPDATE Schwund SET Schwund.BereitsSchwundmarkiertNeu = x.Anzahl
FROM #TmpSchwund AS Schwund, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anzahl
  FROM OPTeile
  WHERE OPTeile.VsaID IN (SELECT VsaID FROM #TmpSchwund)
    AND OPTeile.Status = 'W'
    AND OPTeile.RechPoID = -1
    AND OPTeile.LastScanTime > @bis
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) AS x
WHERE x.VsaID = Schwund.VsaID
  AND x.ArtikelID = Schwund.ArtikelID;

UPDATE Schwund SET Schwund.SchwundGesperrt = x.Anzahl
FROM #TmpSchwund AS Schwund, (
  SELECT OPTeile.VsaID, OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Anzahl
  FROM OPTeile
  WHERE OPTeile.VsaID IN (SELECT VsaID FROM #TmpSchwund)
    AND OPTeile.Status = 'W'
    AND OPTeile.RechPoID = -2
  GROUP BY OPTeile.VsaID, OPTeile.ArtikelID
) AS x
WHERE x.VsaID = Schwund.VsaID
  AND x.ArtikelID = Schwund.ArtikelID;

SELECT KdNr, Kunde, VsaNr, VsaStatus, VsaStichwort, Vsa, Produktbereich, ArtikelNr, Artikelbezeichnung, Durchschnittsliefermenge, Vertragsbestand, SchwundZeitraum, SchwundAlt, BereitsSchwundmarkiertZeitraum, BereitsSchwundmarkiertAlt, BereitsSchwundmarkiertNeu, SchwundGesperrt AS SchwundVerrechnungGesperrt, SchwundZeitraum + BereitsSchwundmarkiertZeitraum AS SchwundVerrechnen, EKPreis AS [EK aktuell], EKPreis * SchwundZeitraum AS Wiederbeschaffungswert
FROM #TmpSchwund
WHERE Vertragsbestand > 0
  OR SchwundZeitraum > 0
  OR SchwundAlt > 0
  OR BereitsSchwundmarkiertZeitraum > 0
  OR BereitsSchwundmarkiertAlt > 0
  OR BereitsSchwundmarkiertNeu > 0
ORDER BY KdNr, VsaNr, ArtikelNr;