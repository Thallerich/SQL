select artikel.ArtikelNr AS SetArtikelNr, artikel.SuchCode AS SetBez, artikel.StueckGewicht AS SetGewicht, artikel1.ArtikelNr AS ArtikelNr, artikel1.SuchCode, artikel1.StueckGewicht, artikel1.Menge
from artikel, (
  SELECT ArtikelID, setartikel.ArtikelNr, setartikel.SuchCode, setartikel.StueckGewicht, Menge
  FROM opsets, (
    SELECT ID, ArtikelNr, SuchCode, StueckGewicht
    FROM artikel) setartikel
  WHERE Artikel1ID = setartikel.ID) artikel1
WHERE ID IN (
  SELECT ArtikelID 
  FROM opsets)
AND BereichID = 106
AND ArtGruID IN (
  SELECT ID
  FROM ArtGru
  WHERE steril = FALSE)
AND artikel.ID = artikel1.ArtikelID
AND Artikel.StueckGewicht <> Artikel1.StueckGewicht;  -- STHA 18.07.2011  nur Differenzen


SELECT Artikel.ArtikelNr, Artikel.SuchCode AS Bezeichnung, Bereich.Bez 
FROM Artikel, Bereich, OpSets, ArtGru
WHERE Artikel.BereichID = Bereich.ID
  AND OpSets.ArtikelID = Artikel.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND ArtGru.Steril = FALSE
  AND Bereich <> 'OP'