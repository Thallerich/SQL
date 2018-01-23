BEGIN TRY
  DROP TABLE #Norm;
END TRY
BEGIN CATCH
END CATCH;

SELECT Bereich.BereichBez$LAN$ AS BereichBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, 0 AS Liefern1, 0 AS Liefern2, 0 AS Liefern3, 0 AS Liefern4, 0 AS Liefern5, 0 AS Liefern6, 0 AS Liefern7, VsaAnf.NormMenge, VsaAnf.SollPuffer, VsaAnf.Durchschnitt, VsaAnf.IstDatum, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, $FALSE$ AS InvTag1, $FALSE$ AS InvTag2, $FALSE$ AS InvTag3, $FALSE$ AS InvTag4, $FALSE$ AS InvTag5, $FALSE$ AS InvTag6, $FALSE$ AS InvTag7, KdBer.ID AS KdBerID, Vsa.ID AS VsaID, Kunden.ID AS KundenID
INTO #Norm
FROM VsaAnf, Vsa, Kunden, KdArti, Artikel, KdBer, Bereich
WHERE VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Kunden.ID = $ID$
  AND (($1$ = 1 AND VsaAnf.MitInventur = 1 AND VsaAnf.Art = 'N') OR ($1$ = 0))
  AND VsaAnf.Status = 'A';

UPDATE Norm SET Norm.Liefern1 = Vsa.NormFaktor1 * Norm.NormMenge, Norm.InvTag1 = Vsa.InvTag1
FROM #Norm AS Norm, VsaTour, Touren, Vsa
WHERE Norm.VsaID = VsaTour.VsaID
  AND Norm.KdBerID = VsaTour.KdBerID
  AND VsaTour.TourenID = Touren.ID
  AND Norm.VsaID = Vsa.ID
  AND Touren.Wochentag = '1';

UPDATE Norm SET Norm.Liefern2 = Vsa.NormFaktor2 * Norm.NormMenge, Norm.InvTag2 = Vsa.InvTag2
FROM #Norm AS Norm, VsaTour, Touren, Vsa
WHERE Norm.VsaID = VsaTour.VsaID
  AND Norm.KdBerID = VsaTour.KdBerID
  AND VsaTour.TourenID = Touren.ID
  AND Norm.VsaID = Vsa.ID
  AND Touren.Wochentag = '2';

UPDATE Norm SET Norm.Liefern3 = Vsa.NormFaktor3 * Norm.NormMenge, Norm.InvTag3 = Vsa.InvTag3
FROM #Norm AS Norm, VsaTour, Touren, Vsa
WHERE Norm.VsaID = VsaTour.VsaID
  AND Norm.KdBerID = VsaTour.KdBerID
  AND VsaTour.TourenID = Touren.ID
  AND Norm.VsaID = Vsa.ID
  AND Touren.Wochentag = '3';

UPDATE Norm SET Norm.Liefern4 = Vsa.NormFaktor4 * Norm.NormMenge, Norm.InvTag4 = Vsa.InvTag4
FROM #Norm AS Norm, VsaTour, Touren, Vsa
WHERE Norm.VsaID = VsaTour.VsaID
  AND Norm.KdBerID = VsaTour.KdBerID
  AND VsaTour.TourenID = Touren.ID
  AND Norm.VsaID = Vsa.ID
  AND Touren.Wochentag = '4';

UPDATE Norm SET Norm.Liefern5 = Vsa.NormFaktor5* Norm.NormMenge, Norm.InvTag5 = Vsa.InvTag5
FROM #Norm AS Norm, VsaTour, Touren, Vsa
WHERE Norm.VsaID = VsaTour.VsaID
  AND Norm.KdBerID = VsaTour.KdBerID
  AND VsaTour.TourenID = Touren.ID
  AND Norm.VsaID = Vsa.ID
  AND Touren.Wochentag = '5';

UPDATE Norm SET Norm.Liefern6 = Vsa.NormFaktor6 * Norm.NormMenge, Norm.InvTag6 = Vsa.InvTag6
FROM #Norm AS Norm, VsaTour, Touren, Vsa
WHERE Norm.VsaID = VsaTour.VsaID
  AND Norm.KdBerID = VsaTour.KdBerID
  AND VsaTour.TourenID = Touren.ID
  AND Norm.VsaID = Vsa.ID
  AND Touren.Wochentag = '6';

UPDATE Norm SET Norm.Liefern7 = Vsa.NormFaktor7 * Norm.NormMenge, Norm.InvTag7 = Vsa.InvTag7
FROM #Norm AS Norm, VsaTour, Touren, Vsa
WHERE Norm.VsaID = VsaTour.VsaID
  AND Norm.KdBerID = VsaTour.KdBerID
  AND VsaTour.TourenID = Touren.ID
  AND Norm.VsaID = Vsa.ID
  AND Touren.Wochentag = '7';

SELECT BereichBez, ArtikelNr, ArtikelBez, VsaNr, Vsa, Liefern1, Liefern2, Liefern3, Liefern4, Liefern5, Liefern6, Liefern7, NormMenge, SollPuffer, Durchschnitt, IstDatum, KdNr, Name1, Name2, Name3, InvTag1, InvTag2, InvTag3, InvTag4, InvTag5, InvTag6, InvTag7, KundenID
FROM #Norm
ORDER BY VsaNr, BereichBez, ArtikelBez;