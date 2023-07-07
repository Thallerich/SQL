DROP TABLE IF EXISTS #TmpResult846a;

DECLARE @from date = $STARTDATE$;
DECLARE @to date = $ENDDATE$;

SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, CAST(0 AS numeric(18,4)) AS Reklamationsmenge, SUM(LsPo.Menge) AS Liefermenge, KdArti.WaschPreis AS Stückpreis, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Holding, Branche.BrancheBez$LAN$ AS Branche, KdArti.ID AS KdArtiID, kunden.id as kundenid, standort.id as standortid
INTO #TmpResult846a
FROM Kunden, Vsa, LsKo, LsPo, KdArti, Artikel, Standort, KdGf, Holding, Branche
WHERE Kunden.ID = Vsa.KundenID
  AND Kunden.KdGfID = KdGf.ID
  AND Vsa.ID = LsKo.VsaID
  AND LsKo.ID = LsPo.LsKoID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.HoldingID = Holding.ID
  AND Kunden.BrancheID = Branche.ID
  AND LsKo.Datum BETWEEN @from AND @to
  AND LsKo.ProduktionID = Standort.ID
  AND Standort.ID IN ($3$)
  AND Holding.ID IN ($4$)
  AND Branche.ID IN ($5$)
  AND LsPo.LsKoGruID NOT IN ($2$)
  AND Artikel.ArtGruID NOT IN (26136, 26137, 26154, 26158) --keine Eigenwäsche
GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.Variante, KdArti.WaschPreis, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Holding.Holding, Branche.BrancheBez$LAN$, KdArti.ID,kunden.id,standort.id;

MERGE INTO #TmpResult846a USING (
  SELECT FORMAT(@from, 'd', 'de-at') + ' - ' + FORMAT(@to, 'd', 'de-at') AS Datumsbereich, Standort.Bez AS Standort, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, SUM(ABS(LsPo.Menge)) AS Reklamationsmenge, SUM(LsPo.Menge) AS Liefermenge, KdArti.WaschPreis AS Stückpreis, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Holding, Branche.BrancheBez$LAN$ AS Branche, KdArti.ID AS KdArtiID, kunden.id as kundenid, standort.id as standortid
  FROM Kunden, Vsa, LsKo, LsPo, KdArti, Artikel, Standort, KdGf, Holding, Branche
  WHERE Kunden.ID = Vsa.KundenID
    AND Kunden.KdGfID = KdGf.ID
    AND Vsa.ID = LsKo.VsaID
    AND LsKo.ID = LsPo.LsKoID
    AND LsPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Kunden.HoldingID = Holding.ID
    AND Kunden.BrancheID = Branche.ID
    AND LsKo.Datum BETWEEN @from AND @to
    AND LsKo.ProduktionID = Standort.ID
    AND Standort.ID IN ($3$)
    AND Holding.ID IN ($4$)
    AND Branche.ID IN ($5$)
    AND LsPo.LsKoGruID IN ($2$)
    AND Artikel.ArtGruID NOT IN (26136, 26137, 26154, 26158) --keine Eigenwäsche
  GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.Variante, KdArti.WaschPreis, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Holding.Holding, Branche.BrancheBez$LAN$, KdArti.ID,kunden.id,standort.id
) AS Reklamationsmenge (Datumsbereich, Standort, Artikelnummer, Artikelbezeichnung, Variante, Reklamationsmenge, Liefermenge, Stückpreis, Geschäftsbereich, KdNr, Kunde, Holding, Branche, KdArtiID,kundenid, standortid)
ON #TmpResult846a.KdArtiID = Reklamationsmenge.KdArtiID and #TmpResult846a.Kundenid = Reklamationsmenge.kundenid and #TmpResult846a.standortid = Reklamationsmenge.standortid
WHEN MATCHED THEN
  UPDATE SET Reklamationsmenge = Reklamationsmenge.Reklamationsmenge, Liefermenge = #TmpResult846a.Liefermenge + Reklamationsmenge.Liefermenge
WHEN NOT MATCHED THEN
  INSERT (Datumsbereich, Standort, Artikelnummer, Artikelbezeichnung, Variante, Reklamationsmenge, Liefermenge, Stückpreis, Geschäftsbereich, KdNr, Kunde, Holding, Branche, KdArtiID,kundenid, standortid)
  VALUES (Reklamationsmenge.Datumsbereich, Reklamationsmenge.Standort, Reklamationsmenge.Artikelnummer, Reklamationsmenge.Artikelbezeichnung, Reklamationsmenge.Variante, Reklamationsmenge.Reklamationsmenge, Reklamationsmenge.Liefermenge, Reklamationsmenge.Stückpreis, Reklamationsmenge.Geschäftsbereich, Reklamationsmenge.KdNr, Reklamationsmenge.Kunde, Reklamationsmenge.Holding, Reklamationsmenge.Branche, Reklamationsmenge.KdArtiID, Reklamationsmenge.kundenid, Reklamationsmenge.standortid);

SELECT Datumsbereich, Standort, Artikelnummer, Artikelbezeichnung, Variante, Reklamationsmenge, Liefermenge, Stückpreis, Geschäftsbereich, KdNr, Kunde, Holding, Branche
FROM #TmpResult846a
WHERE Reklamationsmenge > 0;