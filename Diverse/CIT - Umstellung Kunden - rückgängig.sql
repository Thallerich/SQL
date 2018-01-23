DECLARE @KdNr Integer;
DECLARE @System Integer;

@KdNr = 18100;
@System = 1; -- 1: Tagsys, 2: CountIT

UPDATE VsaAnf SET Status = 'A'
WHERE ID IN (
  SELECT VsaAnf.ID
  FROM VsaAnf, KdArti, Kunden, Artikel, Vsa, __uhfartikel
  WHERE VsaAnf.KdArtiID = KdArti.ID
    AND KdArti.KundenID = Kunden.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Artikel.ArtikelNr = __uhfartikel.ArtikelNr
    AND VsaAnf.VsaID = Vsa.ID
    AND Vsa.SuchCode = __uhfartikel.VsaNr
    AND __uhfartikel.KdNr = @KdNr
    AND Kunden.KdNr = @KdNr
    AND Vsa.StandKonID IN (55, 205)
);

UPDATE VsaAnf SET Status = 'I'
WHERE ID IN (
  SELECT VsaAnf.ID
  FROM VsaAnf, KdArti, Kunden, Artikel, Vsa, __uhfartikel
  WHERE VsaAnf.KdArtiID = KdArti.ID
    AND KdArti.KundenID = Kunden.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Artikel.ArtikelNr = __uhfartikel.ArtikelNrUHF
    AND VsaAnf.VsaID = Vsa.ID
    AND Vsa.SuchCode = __uhfartikel.VsaNr
    AND __uhfartikel.KdNr = @KdNr
    AND Kunden.KdNr = @KdNr
    AND Vsa.StandKonID IN (55, 205)
);

UPDATE Vsa SET Vsa.StandKonID = 55, ReduzPz = $FALSE$, AnzBlankoPZ = 0, ServTypeID = 2
FROM (
  SELECT Vsa.ID AS VsaID, Kunden.AnzBlankoPZ * -1 AS AnzBlankoPZ
  FROM __uhfartikel, Vsa, Kunden
  WHERE __uhfartikel.VsaNr = Vsa.SuchCode
    AND Vsa.KundenID = Kunden.ID
    AND __uhfartikel.KdNr = @KdNr
    AND Kunden.KdNr = @KdNr
    AND Vsa.StandKonID IN (55, 205)
  GROUP BY VsaID, AnzBlankoPZ
) x
WHERE x.VsaID = Vsa.ID;

UPDATE KdBer SET IstBestandAnpass = $FALSE$, AnfAusEPo = 1
FROM (
  SELECT KdBer.ID AS KdBerID
  FROM __uhfartikel, KdBer, KdArti, Artikel, Kunden
  WHERE KdArti.KdBerID = KdBer.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Artikel.ArtikelNr = __uhfartikel.ArtikelNrUHF
    AND KdBer.KundenID = Kunden.ID
    AND Kunden.KdNr = @KdNr
    AND __uhfartikel.KdNr = @KdNr
  GROUP BY KdBerID
) x
WHERE x.KdBerID = KdBer.ID;

UPDATE LsKo SET ProduktionID = 1
WHERE ID IN (
  SELECT LsKo.ID
  FROM LsKo, Vsa, Kunden
  WHERE LsKo.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.KdNr = @KdNr
    AND Vsa.StandKonID = 55 
    AND LsKo.Status < 'Q'
    AND LsKo.Datum >= CURDATE()
    AND LsKo.ProduktionID = 5005
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
    AND Vsa.StandKonID = 55
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

UPDATE AnfKo SET PZArtID = -1, ProduktionID = 1
WHERE ID IN (
  SELECT AnfKoID FROM #TmpAnfCIT
);

/* INSERT INTO AnfExpQ (ID, Typ, AnfKoID, BearbSys, AuftragsNr)
SELECT GetNextID('ANFEXPQ') AS ID, 'U' AS Typ, x.AnfKoID AS AnfKoID, @System AS Bearbsys, x.AuftragsNr
FROM #TmpAnfCIT x
WHERE x.Status = 'I'; */

SELECT 'Kunde ' + CONVERT(@KdNr, SQL_VARCHAR) + ' erfolgreich auf UHF Produktion GP Enns konfiguriert!' AS Text FROM System.IOTA;