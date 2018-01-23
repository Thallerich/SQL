BEGIN TRANSACTION;
  DROP TABLE IF EXISTS #TmpOPSetDrehung;
  DROP TABLE IF EXISTS #TmpOPSetKunde;
COMMIT;

SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.Steril, VsaAnf.Durchschnitt AS Durchschnittsliefermenge, 0 AS Menge7, 0 AS Menge14, 0 AS Menge21, 0 AS Menge30, 0 AS Menge60, 0 AS Menge90, 0 AS Menge180, 0 AS Menge360, 0 AS MengeGesamt, 0 AS DurchschnittTage, Betreuer.Name AS MPB, Vsa.ID AS VsaID, Artikel.ID AS ArtikelID
INTO #TmpOPSetDrehung
FROM VsaAnf, Vsa, Kunden, KdGf, KdArti, Artikel, ArtGru, KdBer, Mitarbei AS Betreuer
WHERE VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BetreuerID = Betreuer.ID
  AND Artikel.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'OP')
  AND ArtGru.ID NOT IN (SELECT ID FROM ArtGru WHERE ArtGruBez = N'Instrumente')
  AND Artikel.ID NOT IN (
    SELECT OPSets.ArtikelID
    FROM OPSets
    WHERE NOT EXISTS (
      SELECT o.*
      FROM OPSets AS o, Artikel
      WHERE o.Artikel1ID = Artikel.ID
        AND Artikel._IstMWID <> 3  -- Set enhält nur Einweg-Artikel
        AND Artikel.ArtikelNr <> N'129899999999' --Trennzeile nicht berücksichtigen
        AND o.ArtikelID = OPSets.ArtikelID
    )
  );

DELETE FROM #TmpOPSetDrehung WHERE ArtikelNr IN (N'300400000000', N'129900000002');

SELECT OPEtiKo.ID AS OPEtiKoID, OPEtiKo.ArtikelID, OPEtiKo.VsaID, DATEDIFF(day, OPEtiKo.AusleseZeitpunkt, GETDATE()) AS TageKunde
INTO #TmpOPSetKunde
FROM OPEtiKo
WHERE OPEtiKo.AusleseZeitpunkt > DATEADD(day, -360, GETDATE())
  AND OPEtiKo.Status = N'R'
  AND OPEtiKo.VsaID IN (SELECT VsaID FROM #TmpOPSetDrehung)
  AND OPEtiKo.ArtikelID IN (SELECT ArtikelID FROM #TmpOPSetDrehung);

UPDATE OPSetDrehung SET Menge7 = x.Menge
FROM #TmpOPSetDrehung AS OPSetDrehung, (
  SELECT OPSetKunde.ArtikelID, OPSetKunde.VsaID, COUNT(OPSetKunde.OPEtiKoID) AS Menge
  FROM #TmpOPSetKunde AS OPSetKunde
  WHERE OPSetKunde.TageKunde <= 7
  GROUP BY OPSetKunde.ArtikelID, OPSetKunde.VsaID
) AS x
WHERE x.ArtikelID = OPSetDrehung.ArtikelID
  AND x.VsaID = OPSetDrehung.VsaID;

UPDATE OPSetDrehung SET Menge14 = x.Menge
FROM #TmpOPSetDrehung AS OPSetDrehung, (
  SELECT OPSetKunde.ArtikelID, OPSetKunde.VsaID, COUNT(OPSetKunde.OPEtiKoID) AS Menge
  FROM #TmpOPSetKunde AS OPSetKunde
  WHERE OPSetKunde.TageKunde > 7
    AND OPSetKunde.TageKunde <= 14
  GROUP BY OPSetKunde.ArtikelID, OPSetKunde.VsaID
) AS x
WHERE x.ArtikelID = OPSetDrehung.ArtikelID
  AND x.VsaID = OPSetDrehung.VsaID;

UPDATE OPSetDrehung SET Menge21 = x.Menge
FROM #TmpOPSetDrehung AS OPSetDrehung, (
  SELECT OPSetKunde.ArtikelID, OPSetKunde.VsaID, COUNT(OPSetKunde.OPEtiKoID) AS Menge
  FROM #TmpOPSetKunde AS OPSetKunde
  WHERE OPSetKunde.TageKunde > 14
    AND OPSetKunde.TageKunde <= 21
  GROUP BY OPSetKunde.ArtikelID, OPSetKunde.VsaID
) AS x
WHERE x.ArtikelID = OPSetDrehung.ArtikelID
  AND x.VsaID = OPSetDrehung.VsaID;

UPDATE OPSetDrehung SET Menge30 = x.Menge
FROM #TmpOPSetDrehung AS OPSetDrehung, (
  SELECT OPSetKunde.ArtikelID, OPSetKunde.VsaID, COUNT(OPSetKunde.OPEtiKoID) AS Menge
  FROM #TmpOPSetKunde AS OPSetKunde
  WHERE OPSetKunde.TageKunde > 21
    AND OPSetKunde.TageKunde <= 30
  GROUP BY OPSetKunde.ArtikelID, OPSetKunde.VsaID
) AS x
WHERE x.ArtikelID = OPSetDrehung.ArtikelID
  AND x.VsaID = OPSetDrehung.VsaID;

UPDATE OPSetDrehung SET Menge60 = x.Menge
FROM #TmpOPSetDrehung AS OPSetDrehung, (
  SELECT OPSetKunde.ArtikelID, OPSetKunde.VsaID, COUNT(OPSetKunde.OPEtiKoID) AS Menge
  FROM #TmpOPSetKunde AS OPSetKunde
  WHERE OPSetKunde.TageKunde > 30
    AND OPSetKunde.TageKunde <= 60
  GROUP BY OPSetKunde.ArtikelID, OPSetKunde.VsaID
) AS x
WHERE x.ArtikelID = OPSetDrehung.ArtikelID
  AND x.VsaID = OPSetDrehung.VsaID;

UPDATE OPSetDrehung SET Menge90 = x.Menge
FROM #TmpOPSetDrehung AS OPSetDrehung, (
  SELECT OPSetKunde.ArtikelID, OPSetKunde.VsaID, COUNT(OPSetKunde.OPEtiKoID) AS Menge
  FROM #TmpOPSetKunde AS OPSetKunde
  WHERE OPSetKunde.TageKunde > 60
    AND OPSetKunde.TageKunde <= 90
  GROUP BY OPSetKunde.ArtikelID, OPSetKunde.VsaID
) AS x
WHERE x.ArtikelID = OPSetDrehung.ArtikelID
  AND x.VsaID = OPSetDrehung.VsaID;

UPDATE OPSetDrehung SET Menge180 = x.Menge
FROM #TmpOPSetDrehung AS OPSetDrehung, (
  SELECT OPSetKunde.ArtikelID, OPSetKunde.VsaID, COUNT(OPSetKunde.OPEtiKoID) AS Menge
  FROM #TmpOPSetKunde AS OPSetKunde
  WHERE OPSetKunde.TageKunde > 90
    AND OPSetKunde.TageKunde <= 180
  GROUP BY OPSetKunde.ArtikelID, OPSetKunde.VsaID
) AS x
WHERE x.ArtikelID = OPSetDrehung.ArtikelID
  AND x.VsaID = OPSetDrehung.VsaID;

UPDATE OPSetDrehung SET Menge360 = x.Menge
FROM #TmpOPSetDrehung AS OPSetDrehung, (
  SELECT OPSetKunde.ArtikelID, OPSetKunde.VsaID, COUNT(OPSetKunde.OPEtiKoID) AS Menge
  FROM #TmpOPSetKunde AS OPSetKunde
  WHERE OPSetKunde.TageKunde > 180
  GROUP BY OPSetKunde.ArtikelID, OPSetKunde.VsaID
) AS x
WHERE x.ArtikelID = OPSetDrehung.ArtikelID
  AND x.VsaID = OPSetDrehung.VsaID;

UPDATE OPSetDrehung SET MengeGesamt = x.Menge
FROM #TmpOPSetDrehung AS OPSetDrehung, (
  SELECT OPSetKunde.ArtikelID, OPSetKunde.VsaID, COUNT(OPSetKunde.OPEtiKoID) AS Menge
  FROM #TmpOPSetKunde AS OPSetKunde
  GROUP BY OPSetKunde.ArtikelID, OPSetKunde.VsaID
) AS x
WHERE x.ArtikelID = OPSetDrehung.ArtikelID
  AND x.VsaID = OPSetDrehung.VsaID;

UPDATE OPSetDrehung SET DurchschnittTage = x.Schnitt
FROM #TmpOPSetDrehung AS OPSetDrehung, (
  SELECT OPSetKunde.ArtikelID, OPSetKunde.VsaID, SUM(OPSetKunde.TageKunde) / COUNT(OPSetKunde.OPEtiKoID) AS Schnitt
  FROM #TmpOPSetKunde AS OPSetKunde
  GROUP BY OPSetKunde.ArtikelID, OPSetKunde.VsaID
) AS x
WHERE x.ArtikelID = OPSetDrehung.ArtikelID
  AND x.VsaID = OPSetDrehung.VsaID;

SELECT OPSetDrehung.SGF, OPSetDrehung.KdNr, OPSetDrehung.Kunde, OPSetDrehung.VsaStichwort, OPSetDrehung.Vsa, OPSetDrehung.ArtikelNr, OPSetDrehung.Artikelbezeichnung, OPSetDrehung.Steril, OPSetDrehung.Durchschnittsliefermenge, OPSetDrehung.Menge7, OPSetDrehung.Menge14, OPSetDrehung.Menge21,OPSetDrehung.Menge30, OPSetDrehung.Menge60, OPSetDrehung.Menge90, OPSetDrehung.Menge180, OPSetDrehung.Menge360,OPSetDrehung.MengeGesamt, OPSetDrehung.DurchschnittTage, OPSetDrehung.MPB
FROM #TmpOPSetDrehung AS OPSetDrehung
WHERE OPSetDrehung.MengeGesamt <> 0
ORDER BY OPSetDrehung.KdNr, OPSetDrehung.VsaStichwort, OPSetDrehung.ArtikelNr;