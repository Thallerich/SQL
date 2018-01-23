-- 591
TRY
	DROP TABLE #TmpAnf;
	DROP TABLE #TmpStand;
	DROP TABLE #TmpData;
CATCH ALL END;

SELECT AnfKo.ID AS AnfKoID, AnfKo.Lieferdatum, AnfKo.Auftragsnr, AnfKo.VsaID, AnfKo.Status, Status.Bez AS PZStatus, AnfPo.KdArtiID
INTO #TmpAnf
FROM AnfKo, AnfPo, Status
WHERE AnfPo.AnfKoID = AnfKo.ID
	AND AnfKo.Status = Status.Status
	AND Status.Tabelle = 'ANFKO'
	AND AnfKo.Lieferdatum = $1$
	AND AnfPo.Angefordert > 0;
	
SELECT DISTINCT Anf.AnfKoID, Anf.Lieferdatum, Anf.Auftragsnr, Anf.VsaID, Anf.Status, Anf.PZStatus, StandBer.*
INTO #TmpStand
FROM StandBer, KdBer, KdArti, #TmpAnf Anf
WHERE Anf.KdArtiID = KdArti.ID
	AND KdArti.KdBerID = KdBer.ID
	AND KdBer.BereichID = StandBer.BereichID
        AND StandBer.ProduktionID IN ($2$);

SELECT Stand.AnfKoID, Standort.Bez AS Produktionsort, Stand.Auftragsnr AS Packzettel, Stand.Status, Stand.PZStatus, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.Bez AS Vsa
INTO #TmpData
FROM Vsa, Kunden, Standort, #TmpStand Stand
WHERE Stand.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Stand.StandKonID = Vsa.StandKonID
	AND Stand.ProduktionID = Standort.ID;

SELECT Data.Produktionsort, Data.Packzettel, Data.Status, Data.PZStatus, Data.KdNr, Data.Kunde, Data.Vsa
FROM #TmpData Data
LEFT OUTER JOIN LsCont ON LsCont.AnfKoID = Data.AnfKoID
WHERE LsCont.AnfKoID IS NULL
GROUP BY Data.Produktionsort, Data.Packzettel, Data.Status, Data.PZStatus, Data.KdNr, Data.Kunde, Data.Vsa

UNION

SELECT Data.Produktionsort, Data.Packzettel, 'K' AS Status, 'In Arbeit' AS PZStatus, Data.KdNr, Data.Kunde, Data.Vsa
FROM #TmpData Data, LsCont
WHERE LsCont.AnfKoID = Data.AnfKoID
	AND Data.Status < 'L'
GROUP BY Data.Produktionsort, Data.Packzettel, Data.KdNr, Data.Kunde, Data.Vsa;


-- 593
SELECT Data.Produktionsort, Data.Status, Data.PZStatus, COUNT(DISTINCT Data.Packzettel) AS Anzahl
FROM (
	SELECT Anf.AnfKoID, Standort.Bez AS Produktionsort, Anf.Auftragsnr AS Packzettel, Status.Status, Status.Bez AS PZStatus, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.Bez AS Vsa
	FROM Vsa, Kunden, StandBer, KdArti, KdBer, Status, Standort, (
		SELECT AnfKo.ID AS AnfKoID, AnfKo.Lieferdatum, AnfKo.Auftragsnr, AnfKo.VsaID, AnfKo.Status, AnfPo.ID AS AnfPoID, AnfPo.KdArtiID
		FROM AnfKo, AnfPo
		WHERE AnfPo.AnfKoID = AnfKo.ID
			AND AnfKo.Lieferdatum = $1$
			AND AnfPo.Angefordert > 0
		) Anf
	WHERE Anf.VsaID = Vsa.ID
		AND Vsa.KundenID = Kunden.ID
		AND Anf.KdArtiID = KdArti.ID
		AND KdArti.KdBerID = KdBer.ID
		AND KdBer.BereichID = StandBer.BereichID
		AND Status.Status = Anf.Status
		AND StandBer.StandKonID = Vsa.StandKonID
		AND StandBer.ProduktionID = Standort.ID
		AND StandBer.ProduktionID IN ($2$)
		AND Anf.Lieferdatum = $1$
		AND Status.Tabelle = 'ANFKO'
	) Data
LEFT OUTER JOIN LsCont ON LsCont.AnfKoID = Data.AnfKoID
WHERE LsCont.AnfKoID IS NULL
GROUP BY Data.Produktionsort, Data.Status, Data.PZStatus

UNION

SELECT Standort.Bez AS Produktionsort, 'K' AS Status, 'In Arbeit' AS PZStatus, COUNT(DISTINCT Anf.Auftragsnr) AS Anzahl
FROM Vsa, Kunden, StandBer, KdArti, KdBer, Standort, LsCont, (
		SELECT AnfKo.ID AS AnfKoID, AnfKo.Lieferdatum, AnfKo.Auftragsnr, AnfKo.VsaID, AnfKo.Status, AnfPo.ID AS AnfPoID, AnfPo.KdArtiID
		FROM AnfKo, AnfPo
		WHERE AnfPo.AnfKoID = AnfKo.ID
			AND AnfKo.Lieferdatum = $1$
		) Anf
WHERE Anf.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Anf.KdArtiID = KdArti.ID
	AND KdArti.KdBerID = KdBer.ID
	AND KdBer.BereichID = StandBer.BereichID
	AND StandBer.StandKonID = StandBer.StandKonID
	AND StandBer.ProduktionID = Standort.ID
	AND LsCont.AnfKoID = Anf.AnfKoID
	AND StandBer.ProduktionID IN ($2$)
	AND Anf.Lieferdatum = $1$
	AND Anf.Status < 'L'
GROUP BY Produktionsort;