DECLARE @KdNr Integer;
DECLARE @System Integer;

@KdNr = 2300;
@System = 2; -- 1: Tagsys, 2: CountIT

TRY
  DROP TABLE #TmpArtiMap;
CATCH ALL END;

SELECT Artikel.ArtikelNr AS ArtikelNrUHF, '10'+RIGHT(TRIM(Artikel.ArtikelNr), LENGTH(Artikel.ArtikelNr) - 2) AS ArtikelNrStandard, VsaAnf.VsaID, 0 AS Normmenge, 0 AS SollPuffer, 0 AS IstPuffer, 0 AS Liefern1, 0 AS Liefern2, 0 AS Liefern3, 0 AS Liefern4, 0 AS Liefern5, 0 AS Liefern6, 0 AS Liefern7, $TRUE$ AS MitInventur, 'M' AS Art
INTO #TmpArtiMap
FROM KdArti, Artikel, Kunden, VsaAnf
WHERE KdArti.ArtikelID = Artikel.ID
  AND KdArti.KundenID = Kunden.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND Kunden.KdNr = @KdNr
  AND Artikel.EAN IS NOT NULL
  AND Artikel.ArtikelNr LIKE '11%'
  AND Artikel.ArtikelNr NOT IN ('111260020001', '114428020001', '117070090000', '114420063201', '117070010055');
  
UPDATE ArtiMap SET Normmenge = VsaAnf.Normmenge, SollPuffer = VsaAnf.SollPuffer, IstPuffer = VsaAnf.IstPuffer, Liefern1 = VsaAnf.Liefern1, Liefern2 = VsaAnf.Liefern2, Liefern3 = VsaAnf.Liefern3, Liefern4 = VsaAnf.Liefern4, Liefern5 = VsaAnf.Liefern5, Liefern6 = VsaAnf.Liefern6, Liefern7 = VsaAnf.Liefern7, MitInventur = VsaAnf.MitInventur, Art = VsaAnf.Art
FROM VsaAnf, KdArti, Artikel, #TmpArtiMap ArtiMap
WHERE VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.ArtikelNr = ArtiMap.ArtikelNrStandard
  AND VsaAnf.VsaID = ArtiMap.VsaID;

UPDATE VsaAnf SET Status = 'A', Normmenge = ArtiMap.NormMenge, SollPuffer = ArtiMap.SollPuffer, IstPuffer = ArtiMap.IstPuffer, Liefern1 = ArtiMap.Liefern1, Liefern2 = ArtiMap.Liefern2, Liefern3 = ArtiMap.Liefern3, Liefern4 = ArtiMap.Liefern4, Liefern5 = ArtiMap.Liefern5, Liefern6 = ArtiMap.Liefern6, Liefern7 = ArtiMap.Liefern7, MitInventur = ArtiMap.MitInventur, Art = ArtiMap.Art, Bestand = 0
FROM VsaAnf, KdArti, Artikel, #TmpArtiMap ArtiMap
WHERE VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND VsaAnf.VsaID = ArtiMap.VsaID
  AND Artikel.ArtikelNr = ArtiMap.ArtikelNrUHF;

UPDATE VsaAnf SET Status = 'I'
WHERE ID IN (
  SELECT VsaAnf.ID
  FROM VsaAnf, KdArti, Kunden, Artikel, Vsa
  WHERE VsaAnf.KdArtiID = KdArti.ID
    AND KdArti.KundenID = Kunden.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND VsaAnf.VsaID = Vsa.ID
    AND Kunden.KdNr = @KdNr
    AND Vsa.StandKonID IN (55, 205)
    AND Artikel.ArtikelNr IN (SELECT ArtikelNrStandard FROM #TmpArtiMap)
);

UPDATE Vsa SET Vsa.StandKonID = 205, ReduzPz = $TRUE$, ServTypeID = 40
FROM (
  SELECT Vsa.ID AS VsaID, Kunden.AnzBlankoPZ * -1 AS AnzBlankoPZ
  FROM Vsa, Kunden
  WHERE Vsa.KundenID = Kunden.ID
    AND Kunden.KdNr = @KdNr
    AND Vsa.StandKonID IN (55, 205)
    AND Vsa.ID IN (SELECT VsaID FROM #TmpArtiMap)
  GROUP BY VsaID, AnzBlankoPZ
) x
WHERE x.VsaID = Vsa.ID;

UPDATE KdBer SET IstBestandAnpass = $TRUE$, AnfAusEPo = 0
FROM (
  SELECT DISTINCT KdBer.ID AS KdBerID
  FROM KdBer, KdArti, Artikel, Kunden
  WHERE KdArti.KdBerID = KdBer.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Artikel.ArtikelNr IN (SELECT ArtikelNrUHF FROM #TmpArtiMap)
    AND KdBer.KundenID = Kunden.ID
    AND Kunden.KdNr = @KdNr
) x
WHERE x.KdBerID = KdBer.ID;

UPDATE LsKo SET ProduktionID = 5005
WHERE ID IN (
  SELECT LsKo.ID
  FROM LsKo, Vsa, Kunden
  WHERE LsKo.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.KdNr = @KdNr
    AND Vsa.StandKonID = 205 
    AND LsKo.Status < 'Q'
    AND LsKo.Datum >= CURDATE()
    AND LsKo.ProduktionID <> 5005
);

TRY
  DROP TABLE #TmpAnfCIT;
CATCH ALL END;

SELECT AnfKo.ID AS AnfKoID, AnfKo.AuftragsNr, AnfKo.Status
INTO #TmpAnfCIT
FROM AnfKo
WHERE AnfKo.VsaID IN (
  SELECT Vsa.ID AS VsaID
  FROM Vsa, Kunden
  WHERE Vsa.KundenID = Kunden.ID
    AND Kunden.KdNr = @KdNr
    AND Vsa.StandKonID = 205 --Produktion GP Enns
    AND EXISTS (
      SELECT VsaAnf.*
      FROM VsaAnf, KdArti, Artikel
      WHERE VsaAnf.KdArtiID = KdArti.ID
        AND KdArti.ArtikelID = Artikel.ID
        AND Artikel.EAN IS NOT NULL
        AND VsaAnf.VsaID = Vsa.ID)
)
  AND AnfKo.Lieferdatum > CURDATE()
  AND AnfKo.PzArtID <> @System;

UPDATE AnfKo SET PZArtID = @System, ProduktionID = 5005
WHERE ID IN (
  SELECT AnfKoID FROM #TmpAnfCIT
);

INSERT INTO AnfExpQ (ID, Typ, AnfKoID, BearbSys, AuftragsNr)
SELECT GetNextID('ANFEXPQ') AS ID, 'U' AS Typ, x.AnfKoID AS AnfKoID, @System AS Bearbsys, x.AuftragsNr
FROM #TmpAnfCIT x
WHERE x.Status = 'I';

UPDATE VsaTexte SET BisDatum = CURDATE() - 1
WHERE ID IN (
  SELECT VsaTexte.ID
  FROM VsaTexte, Vsa, Kunden
  WHERE VsaTexte.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Vsa.StandKonID = 205
    AND VsaTexte.TextArtID = 5
    AND Kunden.KdNr = @KdNr
    AND CURDATE() BETWEEN VsaTexte.VonDatum AND VsaTexte.BisDatum
);

SELECT 'Kunde ' + CONVERT(@KdNr, SQL_VARCHAR) + ' erfolgreich auf UHF Produktion GP Enns konfiguriert!' AS Text FROM System.IOTA;