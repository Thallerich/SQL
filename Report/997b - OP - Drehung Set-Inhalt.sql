/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ prepareData                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #TmpOPTeileDrehung;
DROP TABLE IF EXISTS #TmpOPTeileKunde;

SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Inhaltsartikel.ArtikelNr, Inhaltsartikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.Steril, VsaAnf.Durchschnitt * OPSets.Menge AS Durchschnittsliefermenge, 0 AS Menge7, 0 AS Menge14, 0 AS Menge21, 0 AS Menge30, 0 AS Menge60, 0 AS Menge90, 0 AS Menge180, 0 AS Menge360, 0 AS MengeGesamt, 0 AS DurchschnittTage, Betreuer.Name AS MPB, Vsa.ID AS VsaID, Inhaltsartikel.ID AS ArtikelID, CAST(0 AS bit) AS Ersatzartikel
INTO #TmpOPTeileDrehung
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Mitarbei AS Betreuer ON KdBer.BetreuerID = Betreuer.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
JOIN Artikel AS Inhaltsartikel ON OPSets.Artikel1ID = Inhaltsartikel.ID
JOIN ArtGru ON Inhaltsartikel.ArtGruID = ArtGru.ID
WHERE Inhaltsartikel.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'ST')
  AND ArtGru.ID NOT IN (SELECT ID FROM ArtGru WHERE ArtGruBez = N'Instrumente')
  AND ArtGru.ID IN (SELECT ID FROM ArtGru WHERE SetArtikel = 1)
  AND Inhaltsartikel.ArtikelNr != N'129899999999' /* Trennzeile im Pack-Dialog, kein echter Artikel */
  AND Inhaltsartikel._IstMwID != 3 /* Einweg-Artikel */
;

INSERT INTO #TmpOPTeileDrehung
SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Inhaltsartikel.ArtikelNr, Inhaltsartikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.Steril, VsaAnf.Durchschnitt * OPSets.Menge AS Durchschnittsliefermenge, 0 AS Menge7, 0 AS Menge14, 0 AS Menge21, 0 AS Menge30, 0 AS Menge60, 0 AS Menge90, 0 AS Menge180, 0 AS Menge360, 0 AS MengeGesamt, 0 AS DurchschnittTage, Betreuer.Name AS MPB, Vsa.ID AS VsaID, Inhaltsartikel.ID AS ArtikelID, CAST(1 AS bit) AS Ersatzartikel
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Mitarbei AS Betreuer ON KdBer.BetreuerID = Betreuer.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
JOIN Artikel AS Inhaltsartikel ON OPSets.Artikel2ID = Inhaltsartikel.ID
JOIN ArtGru ON Inhaltsartikel.ArtGruID = ArtGru.ID
WHERE Inhaltsartikel.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'ST')
  AND ArtGru.ID NOT IN (SELECT ID FROM ArtGru WHERE ArtGruBez = N'Instrumente')
  AND ArtGru.ID IN (SELECT ID FROM ArtGru WHERE SetArtikel = 1)
  AND Inhaltsartikel.ArtikelNr != N'129899999999' /* Trennzeile im Pack-Dialog, kein echter Artikel */
  AND Inhaltsartikel._IstMwID != 3 /* Einweg-Artikel */
  AND OPSets.Artikel2ID > 0
;

INSERT INTO #TmpOPTeileDrehung
SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Inhaltsartikel.ArtikelNr, Inhaltsartikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.Steril, VsaAnf.Durchschnitt * OPSets.Menge AS Durchschnittsliefermenge, 0 AS Menge7, 0 AS Menge14, 0 AS Menge21, 0 AS Menge30, 0 AS Menge60, 0 AS Menge90, 0 AS Menge180, 0 AS Menge360, 0 AS MengeGesamt, 0 AS DurchschnittTage, Betreuer.Name AS MPB, Vsa.ID AS VsaID, Inhaltsartikel.ID AS ArtikelID, CAST(1 AS bit) AS Ersatzartikel
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Mitarbei AS Betreuer ON KdBer.BetreuerID = Betreuer.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
JOIN Artikel AS Inhaltsartikel ON OPSets.Artikel3ID = Inhaltsartikel.ID
JOIN ArtGru ON Inhaltsartikel.ArtGruID = ArtGru.ID
WHERE Inhaltsartikel.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'ST')
  AND ArtGru.ID NOT IN (SELECT ID FROM ArtGru WHERE ArtGruBez = N'Instrumente')
  AND ArtGru.ID IN (SELECT ID FROM ArtGru WHERE SetArtikel = 1)
  AND Inhaltsartikel.ArtikelNr != N'129899999999' /* Trennzeile im Pack-Dialog, kein echter Artikel */
  AND Inhaltsartikel._IstMwID != 3 /* Einweg-Artikel */
  AND OPSets.Artikel3ID > 0
  AND NOT EXISTS (
    SELECT *
    FROM #TmpOPTeileDrehung AS x
    WHERE x.ArtikelID = Inhaltsartikel.ID
      AND x.KdNr = Kunden.KdNr
      AND x.VsaID = Vsa.ID
      AND x.Ersatzartikel = 1
  )
;
INSERT INTO #TmpOPTeileDrehung
SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Inhaltsartikel.ArtikelNr, Inhaltsartikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.Steril, VsaAnf.Durchschnitt * OPSets.Menge AS Durchschnittsliefermenge, 0 AS Menge7, 0 AS Menge14, 0 AS Menge21, 0 AS Menge30, 0 AS Menge60, 0 AS Menge90, 0 AS Menge180, 0 AS Menge360, 0 AS MengeGesamt, 0 AS DurchschnittTage, Betreuer.Name AS MPB, Vsa.ID AS VsaID, Inhaltsartikel.ID AS ArtikelID, CAST(1 AS bit) AS Ersatzartikel
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Mitarbei AS Betreuer ON KdBer.BetreuerID = Betreuer.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
JOIN Artikel AS Inhaltsartikel ON OPSets.Artikel4ID = Inhaltsartikel.ID
JOIN ArtGru ON Inhaltsartikel.ArtGruID = ArtGru.ID
WHERE Inhaltsartikel.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'ST')
  AND ArtGru.ID NOT IN (SELECT ID FROM ArtGru WHERE ArtGruBez = N'Instrumente')
  AND ArtGru.ID IN (SELECT ID FROM ArtGru WHERE SetArtikel = 1)
  AND Inhaltsartikel.ArtikelNr != N'129899999999' /* Trennzeile im Pack-Dialog, kein echter Artikel */
  AND Inhaltsartikel._IstMwID != 3 /* Einweg-Artikel */
  AND OPSets.Artikel4ID > 0
  AND NOT EXISTS (
    SELECT *
    FROM #TmpOPTeileDrehung AS x
    WHERE x.ArtikelID = Inhaltsartikel.ID
      AND x.KdNr = Kunden.KdNr
      AND x.VsaID = Vsa.ID
      AND x.Ersatzartikel = 1
  )
;
INSERT INTO #TmpOPTeileDrehung
SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, Inhaltsartikel.ArtikelNr, Inhaltsartikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.Steril, VsaAnf.Durchschnitt * OPSets.Menge AS Durchschnittsliefermenge, 0 AS Menge7, 0 AS Menge14, 0 AS Menge21, 0 AS Menge30, 0 AS Menge60, 0 AS Menge90, 0 AS Menge180, 0 AS Menge360, 0 AS MengeGesamt, 0 AS DurchschnittTage, Betreuer.Name AS MPB, Vsa.ID AS VsaID, Inhaltsartikel.ID AS ArtikelID, CAST(1 AS bit) AS Ersatzartikel
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Mitarbei AS Betreuer ON KdBer.BetreuerID = Betreuer.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
JOIN Artikel AS Inhaltsartikel ON OPSets.Artikel5ID = Inhaltsartikel.ID
JOIN ArtGru ON Inhaltsartikel.ArtGruID = ArtGru.ID
WHERE Inhaltsartikel.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'ST')
  AND ArtGru.ID NOT IN (SELECT ID FROM ArtGru WHERE ArtGruBez = N'Instrumente')
  AND ArtGru.ID IN (SELECT ID FROM ArtGru WHERE SetArtikel = 1)
  AND Inhaltsartikel.ArtikelNr != N'129899999999' /* Trennzeile im Pack-Dialog, kein echter Artikel */
  AND Inhaltsartikel._IstMwID != 3 /* Einweg-Artikel */
  AND OPSets.Artikel5ID > 0
  AND NOT EXISTS (
    SELECT *
    FROM #TmpOPTeileDrehung AS x
    WHERE x.ArtikelID = Inhaltsartikel.ID
      AND x.KdNr = Kunden.KdNr
      AND x.VsaID = Vsa.ID
      AND x.Ersatzartikel = 1
  )
;

SELECT OPEtiKo.ID AS OPEtiKoID, EinzTeil.ArtikelID, OPEtiKo.VsaID, DATEDIFF(day, OPEtiKo.AusleseZeitpunkt, GETDATE()) AS TageKunde, COUNT(EinzTeil.ID) AS AnzInhaltsteile
INTO #TmpOPTeileKunde
FROM OPEtiPo
JOIN OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
JOIN EinzTeil ON OPEtiPo.EinzTeilID = EinzTeil.ID
WHERE OPEtiKo.AusleseZeitpunkt > DATEADD(day, -360, GETDATE())
  AND OPEtiKo.Status = N'R'
  AND OPEtiKo.VsaID IN (SELECT VsaID FROM #TmpOPTeileDrehung)
  AND EinzTeil.ArtikelID IN (SELECT ArtikelID FROM #TmpOPTeileDrehung)
GROUP BY OPEtiKo.ID, EinzTeil.ArtikelID, OPEtiKo.VsaID, DATEDIFF(day, OPEtiKo.AusleseZeitpunkt, GETDATE());

UPDATE OPTeileDrehung SET Menge7 = x.Menge
FROM #TmpOPTeileDrehung AS OPTeileDrehung, (
  SELECT OPTeileKunde.ArtikelID, OPTeileKunde.VsaID, SUM(OPTeileKunde.AnzInhaltsteile) AS Menge
  FROM #TmpOPTeileKunde AS OPTeileKunde
  WHERE OPTeileKunde.TageKunde <= 7
  GROUP BY OPTeileKunde.ArtikelID, OPTeileKunde.VsaID
) AS x
WHERE x.ArtikelID = OPTeileDrehung.ArtikelID
  AND x.VsaID = OPTeileDrehung.VsaID;

UPDATE OPTeileDrehung SET Menge14 = x.Menge
FROM #TmpOPTeileDrehung AS OPTeileDrehung, (
  SELECT OPTeileKunde.ArtikelID, OPTeileKunde.VsaID, SUM(OPTeileKunde.AnzInhaltsteile) AS Menge
  FROM #TmpOPTeileKunde AS OPTeileKunde
  WHERE OPTeileKunde.TageKunde > 7
    AND OPTeileKunde.TageKunde <= 14
  GROUP BY OPTeileKunde.ArtikelID, OPTeileKunde.VsaID
) AS x
WHERE x.ArtikelID = OPTeileDrehung.ArtikelID
  AND x.VsaID = OPTeileDrehung.VsaID;

UPDATE OPTeileDrehung SET Menge21 = x.Menge
FROM #TmpOPTeileDrehung AS OPTeileDrehung, (
  SELECT OPTeileKunde.ArtikelID, OPTeileKunde.VsaID, SUM(OPTeileKunde.AnzInhaltsteile) AS Menge
  FROM #TmpOPTeileKunde AS OPTeileKunde
  WHERE OPTeileKunde.TageKunde > 14
    AND OPTeileKunde.TageKunde <= 21
  GROUP BY OPTeileKunde.ArtikelID, OPTeileKunde.VsaID
) AS x
WHERE x.ArtikelID = OPTeileDrehung.ArtikelID
  AND x.VsaID = OPTeileDrehung.VsaID;

UPDATE OPTeileDrehung SET Menge30 = x.Menge
FROM #TmpOPTeileDrehung AS OPTeileDrehung, (
  SELECT OPTeileKunde.ArtikelID, OPTeileKunde.VsaID, SUM(OPTeileKunde.AnzInhaltsteile) AS Menge
  FROM #TmpOPTeileKunde AS OPTeileKunde
  WHERE OPTeileKunde.TageKunde > 21
    AND OPTeileKunde.TageKunde <= 30
  GROUP BY OPTeileKunde.ArtikelID, OPTeileKunde.VsaID
) AS x
WHERE x.ArtikelID = OPTeileDrehung.ArtikelID
  AND x.VsaID = OPTeileDrehung.VsaID;

UPDATE OPTeileDrehung SET Menge60 = x.Menge
FROM #TmpOPTeileDrehung AS OPTeileDrehung, (
  SELECT OPTeileKunde.ArtikelID, OPTeileKunde.VsaID, SUM(OPTeileKunde.AnzInhaltsteile) AS Menge
  FROM #TmpOPTeileKunde AS OPTeileKunde
  WHERE OPTeileKunde.TageKunde > 30
    AND OPTeileKunde.TageKunde <= 60
  GROUP BY OPTeileKunde.ArtikelID, OPTeileKunde.VsaID
) AS x
WHERE x.ArtikelID = OPTeileDrehung.ArtikelID
  AND x.VsaID = OPTeileDrehung.VsaID;

UPDATE OPTeileDrehung SET Menge90 = x.Menge
FROM #TmpOPTeileDrehung AS OPTeileDrehung, (
  SELECT OPTeileKunde.ArtikelID, OPTeileKunde.VsaID, SUM(OPTeileKunde.AnzInhaltsteile) AS Menge
  FROM #TmpOPTeileKunde AS OPTeileKunde
  WHERE OPTeileKunde.TageKunde > 60
    AND OPTeileKunde.TageKunde <= 90
  GROUP BY OPTeileKunde.ArtikelID, OPTeileKunde.VsaID
) AS x
WHERE x.ArtikelID = OPTeileDrehung.ArtikelID
  AND x.VsaID = OPTeileDrehung.VsaID;

UPDATE OPTeileDrehung SET Menge180 = x.Menge
FROM #TmpOPTeileDrehung AS OPTeileDrehung, (
  SELECT OPTeileKunde.ArtikelID, OPTeileKunde.VsaID, SUM(OPTeileKunde.AnzInhaltsteile) AS Menge
  FROM #TmpOPTeileKunde AS OPTeileKunde
  WHERE OPTeileKunde.TageKunde > 90
    AND OPTeileKunde.TageKunde <= 180
  GROUP BY OPTeileKunde.ArtikelID, OPTeileKunde.VsaID
) AS x
WHERE x.ArtikelID = OPTeileDrehung.ArtikelID
  AND x.VsaID = OPTeileDrehung.VsaID;

UPDATE OPTeileDrehung SET Menge360 = x.Menge
FROM #TmpOPTeileDrehung AS OPTeileDrehung, (
  SELECT OPTeileKunde.ArtikelID, OPTeileKunde.VsaID, SUM(OPTeileKunde.AnzInhaltsteile) AS Menge
  FROM #TmpOPTeileKunde AS OPTeileKunde
  WHERE OPTeileKunde.TageKunde > 180
  GROUP BY OPTeileKunde.ArtikelID, OPTeileKunde.VsaID
) AS x
WHERE x.ArtikelID = OPTeileDrehung.ArtikelID
  AND x.VsaID = OPTeileDrehung.VsaID;

UPDATE OPTeileDrehung SET MengeGesamt = x.Menge
FROM #TmpOPTeileDrehung AS OPTeileDrehung, (
  SELECT OPTeileKunde.ArtikelID, OPTeileKunde.VsaID, SUM(OPTeileKunde.AnzInhaltsteile) AS Menge
  FROM #TmpOPTeileKunde AS OPTeileKunde
  GROUP BY OPTeileKunde.ArtikelID, OPTeileKunde.VsaID
) AS x
WHERE x.ArtikelID = OPTeileDrehung.ArtikelID
  AND x.VsaID = OPTeileDrehung.VsaID;

UPDATE OPTeileDrehung SET DurchschnittTage = x.Schnitt
FROM #TmpOPTeileDrehung AS OPTeileDrehung, (
  SELECT OPTeileKunde.ArtikelID, OPTeileKunde.VsaID, SUM(OPTeileKunde.TageKunde) / SUM(OPTeileKunde.AnzInhaltsteile) AS Schnitt
  FROM #TmpOPTeileKunde AS OPTeileKunde
  GROUP BY OPTeileKunde.ArtikelID, OPTeileKunde.VsaID
) AS x
WHERE x.ArtikelID = OPTeileDrehung.ArtikelID
  AND x.VsaID = OPTeileDrehung.VsaID;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Reportdaten                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT OPTeileDrehung.SGF, OPTeileDrehung.KdNr, OPTeileDrehung.Kunde, OPTeileDrehung.VsaStichwort, OPTeileDrehung.Vsa, OPTeileDrehung.ArtikelNr, OPTeileDrehung.Artikelbezeichnung, OPTeileDrehung.Steril, OPTeileDrehung.Durchschnittsliefermenge, OPTeileDrehung.Menge7, OPTeileDrehung.Menge14, OPTeileDrehung.Menge21,OPTeileDrehung.Menge30, OPTeileDrehung.Menge60, OPTeileDrehung.Menge90, OPTeileDrehung.Menge180, OPTeileDrehung.Menge360,OPTeileDrehung.MengeGesamt, OPTeileDrehung.DurchschnittTage, OPTeileDrehung.MPB
FROM #TmpOPTeileDrehung AS OPTeileDrehung
WHERE OPTeileDrehung.MengeGesamt <> 0
ORDER BY OPTeileDrehung.KdNr, OPTeileDrehung.VsaStichwort, OPTeileDrehung.ArtikelNr;