DECLARE @KdNr Integer;
DECLARE @VsaNr TABLE (VsaNr int);

SET @KdNr = 23032; --Kunde, bei dem die im folgendenen angeführten VSAs umgestellt werden sollen.

INSERT INTO @VsaNr(VsaNr) VALUES (6), (7); --Vsa-Nummern die umgestellt werden sollen.


-- Checkliste Ist-Bestands-Korrektur

DROP TABLE IF EXISTS #OpTeilMeng;

SELECT 
VsaAnf.ID AS VsaAnfID, Kunden.KdNr, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, 
Artikel.ArtikelNr, Artikel.ArtikelBez ArtikelBez, 
IIF(Daten.LastErsatzFuerKdArtiID > 0, Daten.LastErsatzFuerKdArtiID, VsaAnf.KdArtiID) KdArtiID, 
Vsa.ID VsaID, VsaAnf.Bestand SollBestand, VsaAnf.BestandIst VsaAnfBestandIst, 
0 AnzLsUngedruckt, 
COUNT(Daten.ID) AS BestandIst,
SUM(IIF(Daten.LastErsatzFuerKdArtiID <> -1, 1, 0)) VomIstBestandErsatz,
SUM(IIF(Daten.LastErsatzFuerKdArtiID <> -1, 0, 1)) IstBestandOrig,
MIN(Daten.ID) OpTeileID

INTO #OpTeilMeng 

FROM 
(SELECT OpTeile.ID, OpTeile.VsaID, OpTeile.LastErsatzFuerKdArtiID, KdArti.KdBerID, KdArti.ID KdArtiID, KdArti.ArtikelID, KdArti.IstBestandAnpass 
 FROM OpTeile, KdArti, Vsa
 WHERE OpTeile.LastErsatzFuerKdArtiID > -1
 AND OpTeile.LastErsatzFuerKdArtiID = KdArti.ID
 -- Früher: OPTeile.Status='R', Jetzt: OpTeile.LastActionsID = ID_PRODSTAT_OPAUSLESEN
 AND OpTeile.LastActionsID = 102
 AND OpTeile.VsaID > 0
 AND OpTeile.VsaID = Vsa.ID 
 AND Vsa.KundenID = KdArti.KundenID
 UNION ALL
 SELECT OpTeile.ID, OpTeile.VsaID, OpTeile.LastErsatzFuerKdArtiID, KdArti.KdBerID, KdArti.ID KdArtiID, KdArti.ArtikelID, KdArti.IstBestandAnpass
 FROM OpTeile, KdArti, Vsa
 WHERE OpTeile.LastErsatzFuerKdArtiID = -1
 -- Früher: OPTeile.Status='R', Jetzt: OpTeile.LastActionsID = ID_PRODSTAT_OPAUSLESEN
 AND OpTeile.LastActionsID = 102
 AND OpTeile.VsaID > 0
 AND OpTeile.VsaID = Vsa.ID 
 AND Vsa.KundenID = KdArti.KundenID
 AND OpTeile.ArtikelID = KdArti.ArtikelID) Daten, Vsa, kdber, vsaanf, Kunden, Artikel
WHERE Vsa.ID = Daten.VsaID
AND Vsa.KundenID = KdBer.KundenID
AND Kunden.ID = Vsa.KundenID
AND Daten.KdBerID = KdBer.ID
AND Artikel.ID = Daten.ArtikelID
AND ((KdBer.IstBestandAnpass = 1) OR (Daten.IstBestandAnpass = 1))
AND VsaAnf.VsaID = Vsa.ID
AND VsaAnf.KdArtiID = Daten.KdArtiID
AND VsaAnf.ArtGroeID = -1
 
GROUP BY VsaAnf.ID, Kunden.KdNr, Vsa.SuchCode, Vsa.Bez, 
Artikel.ArtikelNr, Artikel.ArtikelBez, 
IIF(Daten.LastErsatzFuerKdArtiID > 0, Daten.LastErsatzFuerKdArtiID, VsaAnf.KdArtiID), Vsa.ID,
VsaAnf.Bestand, VsaAnf.BestandIst;

UPDATE y
SET y.AnzLsUngedruckt = x.Menge
FROM #OpTeilMeng y, (
SELECT VsaID, KdArtiID, SUM(Menge) Menge 
FROM LsKo, LsPo 
WHERE LsKo.Status < 'O'
AND LsKo.ID = LsPo.LsKOID
AND LsKo.VsaID IN (SELECT VsaID FROM #OpTeilMeng)
AND LsPo.KdArtiID IN (SELECT KdArtiID FROM #OpTeilMeng)
GROUP BY VsaID, KdArtiID
) x
WHERE y.KdArtiID = x.KdArtiID
AND y.VsaID = x.VsaID;

UPDATE VsaAnf
SET BestandIst = x.BestandIst,
    VomIstBestandErsatz = x.VomIstBestandErsatz, 
    IstBestandOrig = x.IstBestandOrig
FROM #OpTeilMeng x
WHERE VsaAnf.ID = x.VsaAnfID AND
      (VsaAnf.BestandIst <> x.BestandIst OR
       VsaAnf.VomIstBestandErsatz <> x.VomIstBestandErsatz OR 
       VsaAnf.IstBestandOrig <> x.IstBestandOrig);

-- ENDE: Checkliste Ist-Bestandskorrektur

UPDATE VsaAnf SET BestandIst = 0
WHERE ID IN (
  SELECT VsaAnf.ID
  FROM VsaAnf, Vsa, Kunden, KdArti, Artikel
  WHERE VsaAnf.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND VsaAnf.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Artikel.EAN IS NOT NULL
    AND Artikel.ArtikelNr NOT LIKE N'10%'
    AND Artikel.ArtikelNr <> N'114428020001'
    AND Artikel.BereichID <> 106
    AND Kunden.KdNr = @KdNr
    AND Vsa.VsaNr IN (SELECT VsaNr FROM @VsaNr)
    AND NOT EXISTS (
      SELECT OPTeile.*
      FROM OPTeile
      WHERE OPTeile.VsaID = Vsa.ID
        AND OPTeile.ArtikelID = Artikel.ID
        AND OPTeile.Status = N'Q'
        AND OPTeile.LastActionsID = 102
    )
    AND VsaAnf.BestandIst <> 0
);

DROP TABLE IF EXISTS #TmpVsaAnf;

SELECT VsaAnf.ID, VsaAnf.Status, VsaAnf.BestandIst - (VsaAnf.BestandIst % Artikel.Packmenge) + IIF(VsaAnf.BestandIst % Artikel.Packmenge = 0, 0, Artikel.Packmenge) AS Bestand
INTO #TmpVsaAnf
FROM VsaAnf, KdArti, Artikel, Vsa, Kunden
WHERE VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  --AND VsaAnf.Art IN ('N') -- 'F'
  AND Kunden.KdNr = @KdNr
  AND Artikel.EAN IS NOT NULL --nur gechippte Artikel
  AND Artikel.ArtikelNr NOT LIKE N'10%'  -- keine 10er-Artikel
  AND Artikel.ArtikelNr <> N'114428020001' -- Windel ungebügelt inkl. Chip ausnehmen
  AND Artikel.BereichID <> 106
  AND Vsa.VsaNr IN (SELECT VsaNr FROM @VsaNr);

SELECT * FROM #TmpVsaAnf;

UPDATE VsaAnf SET Art = N'M', Bestand = IIF(x.Status = N'E', 0, x.Bestand), MitInventur = 0, SollPuffer = 0, IstPuffer = 0, IstDatum = NULL, NormMenge = 0, AusstehendeReduz = 0, ReduzAb = NULL --, Liefern1 = 0, Liefern2 = 0, Liefern3 = 0, Liefern4 = 0, Liefern5 = 0, Liefern6 = 0, Liefern7 = 0
FROM VsaAnf, #TmpVsaAnf x
WHERE x.ID = VsaAnf.ID;

DROP TABLE IF EXISTS [#OpTeilMeng];
DROP TABLE IF EXISTS [#TmpVsaAnf];