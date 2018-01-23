TRY
	DROP TABLE #TmpEA;
	DROP TABLE #TmpWEA;
	DROP TABLE #TmpResult;
CATCH ALL END;

SELECT Teile.ID, Teile.Barcode, WEEK(Scans.DateTime) AS WocheEingang, WEEK(Scans.EinAusDat) AS WocheAusgang, IIF(Scans.ZielNrID = 1, 'E', IIF(Scans.ZielNrID = 2, 'A', '')) AS ScanArt
INTO #TmpEA
FROM Scans, Teile, Vsa
WHERE Scans.TeileID = Teile.ID
	AND Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = $ID$
	AND Teile.Status = 'Q'  -- nur aktive Teile
	AND CONVERT(YEAR(Scans.DateTime), SQL_VARCHAR) = $1$
ORDER BY Teile.Barcode, WocheEingang;

SELECT EA.ID AS TeileID, EA.Barcode, IIF(EA.ScanArt = 'E', EA.WocheEingang, IIF(EA.ScanArt = 'A', EA.WocheAusgang, NULL)) AS Woche, EA.ScanArt
INTO #TmpWEA
FROM #TmpEA EA
WHERE EA.ScanArt IN ('E', 'A');

SELECT CONVERT(Kunden.KdNr, SQL_VARCHAR) AS KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, ArtGroe.Groesse, Teile.ID AS TeileID, Teile.Barcode, Teile.ErstDatum AS Ersteinsatz, Teile.IndienstDat AS Einsatzdatum, Teile.RuecklaufG AS Waeschen, Teile.AnzRepair AS Reparaturen, CONVERT(YEAR(CURDATE()), SQL_VARCHAR) AS Jahr, '' AS W01, '' AS W02, '' AS W03, '' AS W04, '' AS W05, '' AS W06, '' AS W07, '' AS W08, '' AS W09, '' AS W10, '' AS W11, '' AS W12, '' AS W13, '' AS W14, '' AS W15, '' AS W16, '' AS W17, '' AS W18, '' AS W19, '' AS W20, '' AS W21, '' AS W22, '' AS W23, '' AS W24, '' AS W25, '' AS W26, '' AS W27, '' AS W28, '' AS W29, '' AS W30, '' AS W31, '' AS W32, '' AS W33, '' AS W34, '' AS W35, '' AS W36, '' AS W37, '' AS W38, '' AS W39, '' AS W40, '' AS W41, '' AS W42, '' AS W43, '' AS W44, '' AS W45, '' AS W46, '' AS W47, '' AS W48, '' AS W49, '' AS W50, '' AS W51, '' AS W52, '' AS W53
INTO #TmpResult
FROM Traeger, ArtGroe, ViewArtikel, Teile, Vsa, Kunden
WHERE Teile.TraegerID = Traeger.ID
	AND Teile.ArtikelID = ViewArtikel.ID
	AND Teile.ArtGroeID = ArtGroe.ID
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.ID = $ID$
	AND Traeger.Status = 'A'  -- nur aktive Träger
	AND Teile.Status = 'Q'  -- nur aktive Teile
	AND ViewArtikel.LanguageID = $LANGUAGE$
ORDER BY VsaNr, Traeger.Traeger, ViewArtikel.ArtikelNr, Teile.Barcode;

UPDATE TR
SET W01 = IIF(W01 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 1;
	
UPDATE TR
SET W02 = IIF(W02 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 2;

UPDATE TR
SET W03 = IIF(W03 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 3;

UPDATE TR
SET W04 = IIF(W04 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 4;

UPDATE TR
SET W05 = IIF(W05 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 5;

UPDATE TR
SET W06 = IIF(W06 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 6;

UPDATE TR
SET W07 = IIF(W07 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 7;

UPDATE TR
SET W08 = IIF(W08 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 8;
	
UPDATE TR
SET W09 = IIF(W09 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 9;

UPDATE TR
SET W10 = IIF(W10 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 10;

UPDATE TR
SET W11 = IIF(W11 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 11;

UPDATE TR
SET W12 = IIF(W12 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 12;

UPDATE TR
SET W13 = IIF(W13 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 13;

UPDATE TR
SET W14 = IIF(W14 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 14;

UPDATE TR
SET W15 = IIF(W15 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 15;

UPDATE TR
SET W16 = IIF(W16 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 16;

UPDATE TR
SET W17 = IIF(W17 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 17;

UPDATE TR
SET W18 = IIF(W18 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 18;

UPDATE TR
SET W19 = IIF(W19 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 19;

UPDATE TR
SET W20 = IIF(W20 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 20;

UPDATE TR
SET W21 = IIF(W21 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 21;

UPDATE TR
SET W22 = IIF(W22 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 22;

UPDATE TR
SET W23 = IIF(W23 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 23;

UPDATE TR
SET W24 = IIF(W24 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 24;

UPDATE TR
SET W25 = IIF(W25 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 25;

UPDATE TR
SET W26 = IIF(W26 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 26;

UPDATE TR
SET W27 = IIF(W27 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 27;

UPDATE TR
SET W28 = IIF(W28 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 28;

UPDATE TR
SET W29 = IIF(W29 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 29;

UPDATE TR
SET W30 = IIF(W30 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 30;

UPDATE TR
SET W31 = IIF(W31 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 31;

UPDATE TR
SET W32 = IIF(W32 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 32;

UPDATE TR
SET W33 = IIF(W33 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 33;

UPDATE TR
SET W34 = IIF(W41 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 34;

UPDATE TR
SET W35 = IIF(W35 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 35;

UPDATE TR
SET W36 = IIF(W36 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 36;

UPDATE TR
SET W37 = IIF(W37 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 37;

UPDATE TR
SET W38 = IIF(W38 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 38;

UPDATE TR
SET W39 = IIF(W39 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 39;

UPDATE TR
SET W40 = IIF(W40 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 40;

UPDATE TR
SET W41 = IIF(W41 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 41;

UPDATE TR
SET W42 = IIF(W42 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 42;

UPDATE TR
SET W43 = IIF(W43 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 43;

UPDATE TR
SET W44 = IIF(W44 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 44;

UPDATE TR
SET W45 = IIF(W45 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 45;

UPDATE TR
SET W46 = IIF(W46 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 46;

UPDATE TR
SET W47 = IIF(W47 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 47;

UPDATE TR
SET W48 = IIF(W48 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 48;

UPDATE TR
SET W49 = IIF(W49 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 49;

UPDATE TR
SET W50 = IIF(W50 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 50;

UPDATE TR
SET W51 = IIF(W51 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 51;

UPDATE TR
SET W52 = IIF(W52 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 52;

UPDATE TR
SET W53 = IIF(W53 = 'E', '*', WEA.ScanArt)
FROM #TmpWEA WEA, #TmpResult TR
WHERE WEA.TeileID = TR.TeileID
	AND WEA.Woche = 53;

SELECT *
FROM #TmpResult;