WITH VsaAnfSuspect AS (
  SELECT VsaAnf.*
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGFID = KdGf.ID
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN VsaBer ON VsaBer.KdBerID = KdBer.ID AND VsaBer.VsaID = Vsa.ID
  JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
  JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
  WHERE KdGf.KurzBez = N'MED'
    AND Produktion.SuchCode LIKE N'WOE_'
    AND UPPER(VsaAnf.Art) = N'M'
    AND VsaAnf.Bestand = 0
    AND VsaAnf.BestandIst != 0
    AND VsaAnf.Status = N'A'
    AND KdBer.AnfAusEpo IN (2, 3)
    AND VsaBer.AnfAusEpo IN (-1, 2, 3)
    AND KdArti.Vertragsartikel = 0
    AND Vsa.Status = N'A'
    AND Kunden.Status = N'A'
    AND KdArti.ErsatzFuerKdArtiID < 0
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBez, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaAnfSuspect.BestandIst AS Istbestand, VsaAnfSuspect.Bestand AS Vertragsbestand
FROM VsaAnfSuspect
JOIN KdArti ON VsaAnfSuspect.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON VsaAnfSuspect.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE EXISTS (
    SELECT OPTeile.*
    FROM OPTeile
    WHERE OPTeile.ArtikelID = KdArti.ArtikelID
      AND OPTeile.VsaID = Vsa.ID
  );

/* WITH VsaAnfSuspect AS (
  SELECT VsaAnf.*
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGFID = KdGf.ID
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN VsaBer ON VsaBer.KdBerID = KdBer.ID AND VsaBer.VsaID = Vsa.ID
  JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
  JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
  WHERE KdGf.KurzBez = N'MED'
    AND Produktion.SuchCode LIKE N'WOE_'
    AND UPPER(VsaAnf.Art) = N'M'
    AND VsaAnf.Bestand = 0
    AND VsaAnf.BestandIst != 0
    AND VsaAnf.Status = N'A'
    AND KdBer.AnfAusEpo IN (2, 3)
    AND VsaBer.AnfAusEpo IN (-1, 2, 3)
    AND KdArti.Vertragsartikel = 0
    AND Vsa.Status = N'A'
    AND Kunden.Status = N'A'
    AND KdArti.ErsatzFuerKdArtiID < 0
)
UPDATE VsaAnf SET Status = N'E', AusstehendeReduz = IIF(VsaAnfSuspect.BestandIst < 0, 0, VsaAnfSuspect.BestandIst), ReduzAb = CAST(GETDATE() AS date)
FROM VsaAnfSuspect
JOIN KdArti ON VsaAnfSuspect.KdArtiID = KdArti.ID
JOIN Vsa ON VsaAnfSuspect.VsaID = Vsa.ID
WHERE VsaAnfSuspect.ID = VsaAnf.ID
  AND EXISTS (
    SELECT OPTeile.*
    FROM OPTeile
    WHERE OPTeile.ArtikelID = KdArti.ArtikelID
      AND OPTeile.VsaID = Vsa.ID
  ); */