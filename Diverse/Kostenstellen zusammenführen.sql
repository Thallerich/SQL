DECLARE @ESIM Integer;
DECLARE @DPX Integer;

@ESIM = 33501360;
@DPX = 33501359;

TRY
  DROP TABLE #TmpESIM;
  DROP TABLE #TmpNonESIM;
  DROP TABLE #TmpLsPoChangeESIM;
  DROP TABLE #TmpLsPoChangeNonESIM;
CATCH ALL END;

SELECT Abteil.ID
INTO #TmpESIM
FROM Abteil
WHERE Abteil.Bez LIKE '%ESIM%'
  AND Abteil.ID <> @ESIM
  AND Abteil.KundenID = (SELECT ID FROM Kunden WHERE KdNr = 3065);
  
SELECT Abteil.ID
INTO #TmpNonESIM
FROM Abteil
WHERE Abteil.Bez NOT LIKE '%ESIM%'
  AND Abteil.ID <> @DPX
  AND Abteil.KundenID = (SELECT ID FROM Kunden WHERE KdNr = 3065);
  
UPDATE AnfPo SET AnfPo.AbteilID = @ESIM
WHERE AnfPo.ID IN (
  SELECT AnfPo.ID
  FROM AnfPo, AnfKo
  WHERE AnfPo.AnfKoID = AnfKo.ID
    AND AnfPo.AbteilID IN (SELECT ID FROM #TmpESIM)
    AND AnfKo.Lieferdatum >= '01.10.2015'
);

UPDATE AnfPo SET AnfPo.AbteilID = @DPX
WHERE AnfPo.ID IN (
  SELECT AnfPo.ID
  FROM AnfPo, AnfKo
  WHERE AnfPo.AnfKoID = AnfKo.ID
    AND AnfPo.AbteilID IN (SELECT ID FROM #TmpNonESIM)
    AND AnfKo.Lieferdatum >= '01.10.2015'
);

SELECT 0 AS LsPoIDneu, LsPo.ID AS LsPoIDalt, LsPo.LsKoID, @ESIM AS AbteilID, LsPo.KdArtiID, LsPo.Kostenlos, LsPo.ArtGroeID, LsPo.VsaOrtID, LsPo.Menge, LsPo.MengeZurueck, LsPo.MengeReserviert, LsPo.MengeEntnommen, LsPo.UrMenge, LsPo.EPreis, LsPo.FehlMenge, LsPo.NachLief, LsPo.ProduktionID, LsPo.EkPreis, LsPo.IstKdArtiPreis, LsPo.IstArtikelPreis, LsPo.LagerOrtID, LsPo.LsKoGruID, LsPo.VpsKoID
INTO #TmpLsPoChangeESIM
FROM LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsPo.AbteilID IN (SELECT ID FROM #TmpESIM)
  AND LsKo.Status < 'W'
;

INSERT INTO LsPo (ID, LsKoID, AbteilID, KdArtiID, Kostenlos, ArtGroeID, VsaOrtID, Menge, MengeZurueck, MengeReserviert, MengeEntnommen, UrMenge, EPreis, FehlMenge, NachLief, ProduktionID, EkPreis, IstKdArtiPreis, IstArtikelPreis, LagerOrtID, LsKoGruID, VpsKoID)
SELECT GetNextID('LSPO') AS ID, LsKoID, AbteilID, KdArtiID, Kostenlos, ArtGroeID, VsaOrtID, SUM(Menge) AS Menge, SUM(MengeZurueck) AS MengeZurueck, SUM(MengeReserviert) AS MengeReserviert, SUM(MengeEntnommen) AS MengeEntnommen, SUM(UrMenge) AS UrMenge, EPreis, SUM(FehlMenge) AS Fehlmenge, SUM(NachLief) AS NachLief, ProduktionID, EkPreis, IstKdArtiPreis, IstArtikelPreis, LagerOrtID, LsKoGruID, VpsKoID
FROM #TmpLsPoChangeESIM
GROUP BY LsKoID, AbteilID, KdArtiID, Kostenlos, ArtGroeID, VsaOrtID, EPreis, ProduktionID, EkPreis, IstKdArtiPreis, IstArtikelPreis, LagerOrtID, LsKoGruID, VpsKoID;

UPDATE LsPoChange SET LsPoChange.LsPoIDneu = LsPo.ID
FROM LsPo, #TmpLsPoChangeESIM AS LsPoChange
WHERE LsPoChange.LsKoID = LsPo.LsKoID
  AND LsPoChange.AbteilID = LsPo.AbteilID
  AND LsPoChange.KdArtiID = LsPo.KdArtiID
  AND LsPoChange.Kostenlos = LsPo.Kostenlos
  AND LsPoChange.ArtGroeID = LsPo.ArtGroeID
  AND LsPoChange.VsaOrtID = LsPo.VsaOrtID
  AND LsPoChange.EPreis = LsPo.EPreis
  AND LsPoChange.ProduktionID = LsPo.ProduktionID
  AND LsPoChange.EkPreis = LsPo.EkPreis
  AND LsPoChange.IstKdArtiPreis = LsPo.IstKdArtiPreis
  AND LsPoChange.IstArtikelPreis = LsPo.IstArtikelPreis
  AND LsPoChange.LagerOrtID = LsPo.LagerOrtID
  AND LsPoChange.LsKoGruID = LsPo.LsKoGruID
  AND LsPoChange.VpsKoID = LsPo.VpsKoID;
  
UPDATE Scans SET Scans.LsPoID = LsPoChange.LsPoIDneu
FROM Scans, #TmpLsPoChangeESIM AS LsPoChange
WHERE Scans.LsPoID = LsPoChange.LsPoIDalt;

DELETE FROM LsPo WHERE LsPo.ID IN (SELECT LsPoIDalt FROM #TmpLsPoChangeESIM);

SELECT 0 AS LsPoIDneu, LsPo.ID AS LsPoIDalt, LsPo.LsKoID, @DPX AS AbteilID, LsPo.KdArtiID, LsPo.Kostenlos, LsPo.ArtGroeID, LsPo.VsaOrtID, LsPo.Menge, LsPo.MengeZurueck, LsPo.MengeReserviert, LsPo.MengeEntnommen, LsPo.UrMenge, LsPo.EPreis, LsPo.FehlMenge, LsPo.NachLief, LsPo.ProduktionID, LsPo.EkPreis, LsPo.IstKdArtiPreis, LsPo.IstArtikelPreis, LsPo.LagerOrtID, LsPo.LsKoGruID, LsPo.VpsKoID
INTO #TmpLsPoChangeNonESIM
FROM LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsPo.AbteilID IN (SELECT ID FROM #TmpNonESIM)
  AND LsKo.Status < 'W'
;

INSERT INTO LsPo (ID, LsKoID, AbteilID, KdArtiID, Kostenlos, ArtGroeID, VsaOrtID, Menge, MengeZurueck, MengeReserviert, MengeEntnommen, UrMenge, EPreis, FehlMenge, NachLief, ProduktionID, EkPreis, IstKdArtiPreis, IstArtikelPreis, LagerOrtID, LsKoGruID, VpsKoID)
SELECT GetNextID('LSPO') AS ID, LsKoID, AbteilID, KdArtiID, Kostenlos, ArtGroeID, VsaOrtID, SUM(Menge) AS Menge, SUM(MengeZurueck) AS MengeZurueck, SUM(MengeReserviert) AS MengeReserviert, SUM(MengeEntnommen) AS MengeEntnommen, SUM(UrMenge) AS UrMenge, EPreis, SUM(FehlMenge) AS Fehlmenge, SUM(NachLief) AS NachLief, ProduktionID, EkPreis, IstKdArtiPreis, IstArtikelPreis, LagerOrtID, LsKoGruID, VpsKoID
FROM #TmpLsPoChangeNonESIM
GROUP BY LsKoID, AbteilID, KdArtiID, Kostenlos, ArtGroeID, VsaOrtID, EPreis, ProduktionID, EkPreis, IstKdArtiPreis, IstArtikelPreis, LagerOrtID, LsKoGruID, VpsKoID;

UPDATE LsPoChange SET LsPoChange.LsPoIDneu = LsPo.ID
FROM LsPo, #TmpLsPoChangeNonESIM AS LsPoChange
WHERE LsPoChange.LsKoID = LsPo.LsKoID
  AND LsPoChange.AbteilID = LsPo.AbteilID
  AND LsPoChange.KdArtiID = LsPo.KdArtiID
  AND LsPoChange.Kostenlos = LsPo.Kostenlos
  AND LsPoChange.ArtGroeID = LsPo.ArtGroeID
  AND LsPoChange.VsaOrtID = LsPo.VsaOrtID
  AND LsPoChange.EPreis = LsPo.EPreis
  AND LsPoChange.ProduktionID = LsPo.ProduktionID
  AND LsPoChange.EkPreis = LsPo.EkPreis
  AND LsPoChange.IstKdArtiPreis = LsPo.IstKdArtiPreis
  AND LsPoChange.IstArtikelPreis = LsPo.IstArtikelPreis
  AND LsPoChange.LagerOrtID = LsPo.LagerOrtID
  AND LsPoChange.LsKoGruID = LsPo.LsKoGruID
  AND LsPoChange.VpsKoID = LsPo.VpsKoID;
  
UPDATE Scans SET Scans.LsPoID = LsPoChange.LsPoIDneu
FROM Scans, #TmpLsPoChangeNonESIM AS LsPoChange
WHERE Scans.LsPoID = LsPoChange.LsPoIDalt;

DELETE FROM LsPo WHERE LsPo.ID IN (SELECT LsPoIDalt FROM #TmpLsPoChangeNonESIM);

UPDATE Schrank SET Schrank.AbteilID = @ESIM
WHERE Schrank.ID IN (
  SELECT Schrank.ID
  FROM Schrank
  WHERE Schrank.AbteilID IN (SELECT ID FROM #TmpESIM)
);

UPDATE Schrank SET Schrank.AbteilID = @DPX
WHERE Schrank.ID IN (
  SELECT Schrank.ID
  FROM Schrank
  WHERE Schrank.AbteilID IN (SELECT ID FROM #TmpNonESIM)
);

UPDATE Traeger SET Traeger.AbteilID = @ESIM
WHERE Traeger.ID IN (
  SELECT Traeger.ID
  FROM Traeger
  WHERE Traeger.AbteilID IN (SELECT ID FROM #TmpESIM)
);

UPDATE Traeger SET Traeger.AbteilID = @DPX
WHERE Traeger.ID IN (
  SELECT Traeger.ID
  FROM Traeger
  WHERE Traeger.AbteilID IN (SELECT ID FROM #TmpNonESIM)
);

UPDATE Vsa SET Vsa.AbteilID = @ESIM
WHERE Vsa.ID IN (
  SELECT Vsa.ID
  FROM Vsa
  WHERE Vsa.AbteilID IN (SELECT ID FROM #TmpESIM)
);

UPDATE Vsa SET Vsa.AbteilID = @DPX
WHERE Vsa.ID IN (
  SELECT Vsa.ID
  FROM Vsa
  WHERE Vsa.AbteilID IN (SELECT ID FROM #TmpNonESIM)
);

UPDATE VsaAnf SET VsaAnf.AbteilID = @ESIM
WHERE VsaAnf.ID IN (
  SELECT VsaAnf.ID
  FROM VsaAnf
  WHERE VsaAnf.AbteilID IN (SELECT ID FROM #TmpESIM)
);

UPDATE VsaAnf SET VsaAnf.AbteilID = @DPX
WHERE VsaAnf.ID IN (
  SELECT VsaAnf.ID
  FROM VsaAnf
  WHERE VsaAnf.AbteilID IN (SELECT ID FROM #TmpNonESIM)
);

UPDATE VsaLeas SET VsaLeas.AbteilID = @ESIM
WHERE VsaLeas.ID IN (
  SELECT VsaLeas.ID
  FROM VsaLeas
  WHERE VsaLeas.AbteilID IN (SELECT ID FROM #TmpESIM)
);

UPDATE VsaLeas SET VsaLeas.AbteilID = @DPX
WHERE VsaLeas.ID IN (
  SELECT VsaLeas.ID
  FROM VsaLeas
  WHERE VsaLeas.AbteilID IN (SELECT ID FROM #TmpNonESIM)
);