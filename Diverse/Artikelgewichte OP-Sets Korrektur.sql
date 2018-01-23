select distinct artikel.ID, artikel.Stueckgewicht/artikel.PackMenge AS SetGewichtNeu
into #TmpSetGewicht
from artikel, (
  SELECT ArtikelID, setartikel.ArtikelNr, setartikel.SuchCode, setartikel.StueckGewicht, Menge
  FROM opsets, (
    SELECT ID, ArtikelNr, SuchCode, StueckGewicht
    FROM artikel) setartikel
  WHERE Artikel1ID = setartikel.ID) artikel1
WHERE ID IN (
  SELECT ArtikelID 
  FROM opsets)
AND ArtGruID IN (
  SELECT ID
  FROM ArtGru
  WHERE steril = FALSE)
AND artikel.ID = artikel1.ArtikelID
AND artikel.PackMenge > 1;

UPDATE Artikel
SET Artikel.Stueckgewicht = (
	SELECT tsg.SetGewichtNeu
	FROM #TmpSetGewicht tsg
	WHERE tsg.ID = Artikel.ID)
WHERE EXISTS (
	SELECT *
	FROM #TmpSetGewicht tsg1
	WHERE tsg1.ID = Artikel.ID);
	
DROP TABLE #TmpSetGewicht;