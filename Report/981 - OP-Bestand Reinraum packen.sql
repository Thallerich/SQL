DECLARE @SchnittWochen integer;
DECLARE @LsSchnittVon date;

SET @SchnittWochen = (SELECT CONVERT(integer, ValueMemo) FROM Settings WHERE Parameter = 'ANF_MITTEL_WOCHENSCHNITT');
SET @LsSchnittVon = DATEADD(week, @SchnittWochen * -1, GETDATE());

DROP TABLE IF EXISTS #TmpOPBestand;

SELECT Artikel.ID AS ArtikelID, Status.StatusBez$LAN$ AS Artikelstatus, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 0 AS LiefermengeSchnitt, 0 AS inProd, 0 AS Qualitaetskontrolle, 0 AS Fehlerhaft, 0 AS Teilelager, 0 AS EingangUnrein, 0 AS AbweichungAnfQK, 0 AS Schrott, 0 AS Neu, 0 AS Angefordert, 0 AS Gepackt, 0 AS Umlaufmenge, 0 AS FehlmengeVortag, 0 AS ErsatzmengeVortag, 0 AS AnfErsatzVortag, 0 AS Drehung
INTO #TmpOPBestand
FROM Artikel, Bereich, Status
WHERE Artikel.BereichID = Bereich.ID
  AND Artikel.Status = Status.Status
  AND Status.Tabelle = 'ARTIKEL'
  AND Artikel.Status <> 'I'
  AND Bereich.Bereich = 'ST'
  AND Artikel.ID NOT IN (SELECT OPSets.ArtikelID FROM OPSets) -- nur Nicht-Set-Artikel
  --AND Artikel.ArtikelNr IN ('129800037000', '129802201000', '129802211000', '129802301000', '129802311000', '129805001000', '129805011000', '129805021000', '129805061000', '129805071000', '129805201000', '129805681000', '129805981000', '129805991000', '129806151000', '129806251000', '129806461000', '129807001000', '129807007000', '129807011000', '129807012000', '129807018200', '129807041000', '129807047000', '129807061000', '129807081000', '129807087000', '129807091000', '129807101000', '129807111000', '129807113000', '129807114000', '129807117000', '129807118000', '129807121000', '129807131000', '129807132000', '129807137000', '129807141000', '129807148200', '129807151000', '129807157000', '129807162000', '129807163000', '129807167000', '129807168200', '129807177000', '129807191000', '129807211000', '129807212000', '129807213000', '129807217000', '129807241000', '129807251000', '129807257000', '129807261000', '129807267000', '129807291000', '129807301000', '129807302000', '129807321000', '129807327000', '129807331000', '129807341000', '129807351000', '129807361000', '129807373000', '129807374000', '129807381000', '129807411000', '129807417000', '129807421000', '129807430000', '129807461000', '129807521000', '129807527000', '129807531000', '129807552000', '129807553000', '129807591000', '129807592000', '129807597000', '129807601000', '129807611000', '129807621000', '129807621001', '129807622000', '129807624000', '129807627000', '129807631000', '129807681000', '129807681001', '129807691000', '129807701000', '129807702000', '129807711000', '129807761000', '129807771000', '129807781000', '129807787000', '129807800000', '129807811000', '129807812000', '129807813000', '129807831000', '129807871000', '129807872001', '129807873000', '129807875000', '129807881000', '129807921000', '129807931000', '129807932000', '129807938000', '129807938100', '12980793W000', '129807961000', '129807971000', '129807972000', '129808001000', '129808031000', '129808032000', '129808041000', '129808042000', '129808042001', '129808051000', '129808071000', '129808072000', '129808077000', '129808111000', '129808121000', '129808131000', '129808141000', '129808161000', '129808301000', '129808311000', '129808321000', '129808331000', '129808351000', '129808361000', '129808371000', '129808381000', '129808388000', '129808441000', '129808442000', '129808444000', '129808447000', '129808690000', '129808711000', '129808731000', '129808771000', '129808773000', '129808801000', '129808802000', '129808804000', '129808811000', '129808819000', '129808821000', '129808831000', '129808867000', '129808868000', '129808872000', '129808877000', '129808881000', '129808901000', '129808911000', '129808912000', '129808921000', '129808929000', '129809882000', '129809883001', '129809887000', '129809897000', '129811631002', '129870051000', '129870051001', '129870091000', '129870091002', '129871001000', '129876251000', '129876257000', '129876461000', '129876462000', '129877831000', '129878041000', '129878301000', '129878351000', '129878441000', '129878447000', '129878700000', '129878710000', '129889802000', '129820000000')
GROUP BY Artikel.ID, Status.StatusBez$LAN$, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$;

UPDATE OPBestand SET OPBestand.Umlaufmenge = x.Menge
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS Menge
  FROM OPTeile
  WHERE OPTeile.Status IN (N'A', N'Q')
    AND DATEDIFF(month, OPTeile.LastScanTime, GETDATE()) <= 6 --nur Teile mit letztem Scan innerhalb von 6 Monaten
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET OPBestand.Qualitaetskontrolle = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status IN (N'A', N'Q')
    AND OPTeile.LastActionsID = 109
    AND DATEDIFF(month, OPTeile.LastScanTime, GETDATE()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET OPBestand.Fehlerhaft = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status IN (N'A', N'Q')
    AND OPTeile.LastActionsID IN (104, 105, 106)  --Chemisch, Nachwäsche, Reparatur
    AND DATEDIFF(month, OPTeile.LastScanTime, GETDATE()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET OPBestand.Teilelager = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status IN (N'A', N'Q')
    AND OPTeile.LastActionsID = 107
    AND DATEDIFF(month, OPTeile.LastScanTime, GETDATE()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET OPBestand.EingangUnrein = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status IN (N'A', N'Q')
    AND OPTeile.LastActionsID = 100
    AND DATEDIFF(month, OPTeile.LastScanTime, GETDATE()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
    AND OPTeile.ZielNrID = 300
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET OPBestand.Gepackt = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status IN (N'A', N'Q')
    AND OPTeile.LastActionsID IN (101, 113, 114)  -- Packen, steril, unsteril
    AND DATEDIFF(month, OPTeile.LastScanTime, GETDATE()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET OPBestand.Schrott = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status = 'Z'
    AND OPTeile.WegDatum >= CONVERT(date, '01.01.' + CONVERT(char(4), YEAR(GETDATE())))
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET OPBestand.Neu = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status IN (N'A', N'Q')
    AND OPTeile.Erstwoche >= CONVERT(char(4), YEAR(GETDATE())) + '/01'
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET OPBestand.Angefordert = x.Angefordert
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPSets.Artikel1ID AS ArtikelID, SUM(AnfPo.Angefordert * OPSets.Menge / Artikel.Packmenge) AS Angefordert --Division durch Packmenge wegen unsterilen Artikeln (Spezialfall!)
  FROM Artikel, KdArti, OPSets, (
    SELECT AnfPo.*
    FROM AnfPo, AnfKo, Vsa
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND AnfKo.VsaID = Vsa.ID
      AND Vsa.StandKonID IN (58, 205) -- OP:Enns, Produktion GP Enns
      AND ((DATEPART(weekday, DATEADD(day, 1, GETDATE())) <= 5 AND AnfKo.LieferDatum = DATEADD(day, 1, CONVERT(date, GETDATE()))) OR (DATEPART(weekday, DATEADD(day, 1, GETDATE())) > 5 AND AnfKo.LieferDatum BETWEEN DATEADD(day, 1, CONVERT(date, GETDATE())) AND DATEADD(day, 3, CONVERT(date, GETDATE()))))
      AND AnfKo.Status >= 'F'
      AND AnfKo.Lieferdatum >= DATEADD(day, 1, CONVERT(date, GETDATE()))
  ) AS AnfPo
  WHERE AnfPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.ArtikelID = OPSets.ArtikelID
    AND OPSets.Artikel1ID IN (SELECT ArtikelID FROM #TmpOPBestand)
    AND OPSets.ID > 0
  GROUP BY OPSets.Artikel1ID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE #TmpOPBestand SET AbweichungAnfQK = Qualitaetskontrolle - Angefordert;

UPDATE OPBestand SET OPBestand.FehlmengeVortag = x.Fehlmenge
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPSets.Artikel1ID AS ArtikelID, SUM((AnfPo.Angefordert - AnfPo.Geliefert) * OPSets.Menge / Artikel.Packmenge) AS Fehlmenge  --Division durch Packmenge wegen unsterilen Artikeln (Spezialfall!)
  FROM Artikel, KdArti, OPSets, (
    SELECT AnfPo.*
    FROM AnfPo, AnfKo, Vsa
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND AnfKo.VsaID = Vsa.ID
      AND Vsa.StandKonID IN (58, 205) -- OP:Enns, Produktion GP Enns
      AND ((DATEPART(weekday, GETDATE()) <= 5 AND AnfKo.LieferDatum = CONVERT(date, GETDATE())) OR (DATEPART(weekday, GETDATE()) > 5 AND AnfKo.LieferDatum BETWEEN CONVERT(date, GETDATE()) AND CONVERT(date, GETDATE() + 2)))
      AND AnfKo.Status >= 'F'
      AND AnfKo.Lieferdatum >= CONVERT(date, GETDATE())
      AND AnfPo.Geliefert < AnfPo.Angefordert
  ) AS AnfPo
  WHERE AnfPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND KdArti.ArtikelID = OPSets.ArtikelID
    AND OPSets.Artikel1ID IN (SELECT ArtikelID FROM #TmpOPBestand)
    AND OPSets.ID > 0
  GROUP BY OPSets.Artikel1ID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

DROP TABLE IF EXISTS #TmpErsatzVortag;

SELECT OPTeile.ArtikelID, OPEtiKo.Status, COUNT(OPTeile.ID) AS Menge
INTO #TmpErsatzVortag
FROM OPEtiPo, OPTeile, OPEtiKo, AnfPo, AnfKo, Vsa
WHERE OPEtiPo.OPTeileID = OPTeile.ID
  AND OPEtiPo.OPEtiKoID = OPEtiKo.ID
  AND OPEtiKo.AnfPoID = AnfPo.ID
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.StandKonID IN (58, 205) -- OP:Enns, Produktion GP Enns
  AND ((DATEPART(weekday, GETDATE()) <= 5 AND AnfKo.LieferDatum = CONVERT(date, GETDATE())) OR (DATEPART(weekday, GETDATE()) > 5 AND AnfKo.LieferDatum BETWEEN CONVERT(date, GETDATE()) AND CONVERT(date, GETDATE() + 2)))
  AND AnfKo.Status >= 'F'
  AND AnfKo.Lieferdatum >= CONVERT(date, GETDATE())
  AND OPEtiPo.Ersatzartikel = $TRUE$
  AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
GROUP BY OPTeile.ArtikelID, OPEtiKo.Status;

UPDATE OPBestand SET OPBestand.ErsatzmengeVortag = x.Menge
FROM #TmpOPBestand AS OPBestand, (
  SELECT ErsatzVortag.ArtikelID, SUM(ErsatzVortag.Menge) AS Menge
  FROM #TmpErsatzVortag AS ErsatzVortag
  WHERE ErsatzVortag.Status >= 'J'
  GROUP BY ErsatzVortag.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

DROP TABLE IF EXISTS #TmpErsatzAnfVortag;

SELECT OPSets.Artikel1ID, OPEtiKo.Status, COUNT(OPEtiPo.ID) AS Menge
INTO #TmpErsatzAnfVortag
FROM OPEtiPo, OPSets, OPEtiKo, AnfPo, AnfKo, Vsa
WHERE OPEtiPo.OPSetsID = OPSets.ID
  AND OPEtiPo.OPEtiKoID = OPEtiKo.ID
  AND OPEtiKo.AnfPoID = AnfPo.ID
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.StandKonID IN (58, 205) -- OP:Enns, Produktion GP Enns
  AND ((DATEPART(weekday, GETDATE()) <= 5 AND AnfKo.LieferDatum = CONVERT(date, GETDATE())) OR (DATEPART(weekday, GETDATE()) > 5 AND AnfKo.LieferDatum BETWEEN CONVERT(date, GETDATE()) AND CONVERT(date, GETDATE() + 2)))
  AND AnfKo.Status >= 'F'
  AND AnfKo.Lieferdatum >= CONVERT(date, GETDATE())
  AND OPEtiPo.Ersatzartikel = $TRUE$
  AND OPSets.Artikel1ID IN (SELECT ArtikelID FROM #TmpOPBestand)
  AND OPSets.ID > 0
GROUP BY OPSets.Artikel1ID, OPEtiKo.Status;

UPDATE OPBestand SET OPBestand.AnfErsatzVortag = x.Menge
FROM #TmpOPBestand AS OPBestand, (
  SELECT ErsatzAnfVortag.Artikel1ID, SUM(ErsatzAnfVortag.Menge) AS Menge
  FROM #TmpErsatzAnfVortag AS ErsatzAnfVortag
  WHERE ErsatzAnfVortag.Status >= 'J'
  GROUP BY ErsatzAnfVortag.Artikel1ID
) AS x
WHERE x.Artikel1ID = OPBestand.ArtikelID;

UPDATE OPBestand SET LiefermengeSchnitt = LTData.LiefermengeInhalt / @SchnittWochen / 2 -- 1/2 Durchschnittsliefermenge der letzten x Wochen für den jeweiligen Liefertag
FROM #TmpOPBestand AS OPBestand, (
  SELECT SUM(Ls.Liefermenge * OPSets.Menge) AS LiefermengeInhalt, OPSets.Artikel1ID AS ArtikelIDInhalt
  FROM OPSets, (
    SELECT KdArti.ArtikelID, SUM(LsPo.Menge) AS Liefermenge, DATEPART(weekday, LsKo.Datum) AS Wochentag
    FROM LsPo, LsKo, KdArti, Vsa
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.KdArtiID = KdArti.ID
      AND LsKo.VsaID = Vsa.ID
      AND Vsa.StandKonID IN (58, 205) -- OP:Enns, Produktion GP Enns
      AND LsKo.Datum BETWEEN @LsSchnittVon AND CONVERT(date, GETDATE())
      AND KdArti.ArtikelID IN (SELECT OPSets.ArtikelID FROM OPSets, #TmpOPBestand OPBestand WHERE OPSets.Artikel1ID = OPBestand.ArtikelID)
    GROUP BY KdArti.ArtikelID, DATEPART(weekday, LsKo.Datum)
  ) AS Ls
  WHERE Ls.ArtikelID = OPSets.ArtikelID
    AND OPSets.ID > 0
    AND ((DATEPART(weekday, GETDATE()) <= 5 AND Ls.Wochentag = DATEPART(weekday, GETDATE() + 1)) OR (DATEPART(weekday, GETDATE()) > 5 AND Ls.Wochentag IN (7, 2)))
  GROUP BY OPSets.Artikel1ID
) AS LTData
WHERE LTData.ArtikelIDInhalt = OPBestand.ArtikelID;

UPDATE OPBestand SET Drehung = ISNULL(x.DrehungSchnitt, 0)
FROM (
  SELECT OPTeile.ArtikelID, SUM(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE())) / COUNT(OPTeile.ID) AS DrehungSchnitt
  FROM OPTeile
  WHERE OPTeile.Status IN (N'A', N'Q')
    AND OPTeile.LastActionsID = 102  -- ausgelesen
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
    AND DATEDIFF(month, OPTeile.LastScanTime, GETDATE()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
  GROUP BY OPTeile.ArtikelID
) AS x, #TmpOPBestand AS OPBestand
WHERE OPBestand.ArtikelID = x.ArtikelID;

SELECT ArtikelNr, Artikelbezeichnung, Artikelstatus, LiefermengeSchnitt AS [1/2 Durchschnittsliefermenge], Qualitaetskontrolle, Fehlerhaft, Teilelager, EingangUnrein AS [Voraviso Unrein], Umlaufmenge, Schrott AS [Schrott seit Jahresbeginn], Neu AS [Neu seit Jahresbeginn], FehlmengeVortag + AnfErsatzVortag AS FehlmengeVortag, ErsatzmengeVortag AS [Verwendet als Ersatzartikel (Vortag)], AnfErsatzVortag AS [Anforderung über Ersatzartikel abgedeckt (Vortag)], Drehung, Angefordert, Gepackt, IIF(Angefordert - Gepackt < 0, 0, Angefordert - Gepackt) AS Benoetigt, AbweichungAnfQK AS [Abweichung Angefordert - Kontrolliert]
FROM #TmpOPBestand x;