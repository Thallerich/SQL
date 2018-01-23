DECLARE @SchnittWochen INTEGER;
DECLARE @LsSchnittVon DATE;

@SchnittWochen = (SELECT CONVERT(ValueMemo, SQL_INTEGER) FROM Settings WHERE Parameter = 'ANF_MITTEL_WOCHENSCHNITT');
@LsSchnittVon = CONVERT(TIMESTAMPADD(SQL_TSI_WEEK, @SchnittWochen * -1, NOW()), SQL_DATE);

TRY
  DROP TABLE #TmpOPBestand;
CATCH ALL END;

SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, 0 AS LiefermengeSchnitt, 0 AS inProd, 0 AS Qualitaetskontrolle, 0 AS EingangUnrein, 0 AS AbweichungAnfQK, 0 AS Schrott20Tage, 0 AS Neu20Tage, 0 AS Angefordert, 0 AS Gepackt, COUNT(OPTeile.ID) AS Umlaufmenge, 0 AS FehlmengeVortag
INTO #TmpOPBestand
FROM OPTeile, Artikel, Bereich
WHERE OPTeile.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Bereich.Bereich = 'OP'
  AND OPTeile.Status BETWEEN 'A' AND 'R'
  AND TIMESTAMPDIFF(SQL_TSI_MONTH, OPTeile.LastScanTime, NOW()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
  AND Artikel.ArtikelNr IN ('129800037000', '129802201000', '129802211000', '129802301000', '129802311000', '129805001000', '129805011000', '129805021000', '129805061000', '129805071000', '129805201000', '129805681000', '129805981000', '129805991000', '129806151000', '129806251000', '129806461000', '129807001000', '129807007000', '129807011000', '129807012000', '129807018200', '129807041000', '129807047000', '129807061000', '129807081000', '129807087000', '129807091000', '129807101000', '129807111000', '129807113000', '129807114000', '129807117000', '129807118000', '129807121000', '129807131000', '129807132000', '129807137000', '129807141000', '129807148200', '129807151000', '129807157000', '129807162000', '129807163000', '129807167000', '129807168200', '129807177000', '129807191000', '129807211000', '129807212000', '129807213000', '129807217000', '129807241000', '129807251000', '129807257000', '129807261000', '129807267000', '129807291000', '129807301000', '129807302000', '129807321000', '129807327000', '129807331000', '129807341000', '129807351000', '129807361000', '129807373000', '129807374000', '129807381000', '129807411000', '129807417000', '129807421000', '129807430000', '129807461000', '129807521000', '129807527000', '129807531000', '129807552000', '129807553000', '129807591000', '129807592000', '129807597000', '129807601000', '129807611000', '129807621000', '129807621001', '129807622000', '129807624000', '129807627000', '129807631000', '129807681000', '129807681001', '129807691000', '129807701000', '129807702000', '129807711000', '129807761000', '129807771000', '129807781000', '129807787000', '129807800000', '129807811000', '129807812000', '129807813000', '129807831000', '129807871000', '129807872001', '129807873000', '129807875000', '129807881000', '129807921000', '129807931000', '129807932000', '129807938000', '129807938100', '12980793W000', '129807961000', '129807971000', '129807972000', '129808001000', '129808031000', '129808032000', '129808041000', '129808042000', '129808042001', '129808051000', '129808071000', '129808072000', '129808077000', '129808111000', '129808121000', '129808131000', '129808141000', '129808161000', '129808301000', '129808311000', '129808321000', '129808331000', '129808351000', '129808361000', '129808371000', '129808381000', '129808388000', '129808441000', '129808442000', '129808444000', '129808447000', '129808690000', '129808711000', '129808731000', '129808771000', '129808773000', '129808801000', '129808802000', '129808804000', '129808811000', '129808819000', '129808821000', '129808831000', '129808867000', '129808868000', '129808872000', '129808877000', '129808881000', '129808901000', '129808911000', '129808912000', '129808921000', '129808929000', '129809882000', '129809883001', '129809887000', '129809897000', '129811631002', '129870051000', '129870051001', '129870091000', '129870091002', '129871001000', '129876251000', '129876257000', '129876461000', '129876462000', '129877831000', '129878041000', '129878301000', '129878351000', '129878441000', '129878447000', '129878700000', '129878710000', '129889802000', 'O562000510-45', 'O562000512-45', 'O562000610-45', 'O562050720-24', 'O562078710-70', 'O562078730', 'O562078810-70', 'O562080710-70', 'O562098820-07', 'O562098910-70', 'O563050010-07', 'O563050110-07', 'O563050610-07', 'O563056810-07', 'O563059810-07', 'O563062510-07', 'O563064610-07', 'O563070010-70', 'O563070110-07', 'O563070410-70', 'O563070610-07', 'O563070810-70', 'O563071000-70', 'O563071110-70', 'O563071210-07', 'O563071310-07', 'O563071510-70', 'O563071910-70', 'O563072410-07', 'O563072510-07', 'O563072610-07', 'O563072910-70', 'O563073010-70', 'O563074110-70', 'O563074210-07', 'O563074610-70', 'O563075210-70', 'O563076010-70', 'O563076110-70', 'O563076210-70', 'O563076220-70', 'O563076310-70', 'O563076810-70', 'O563076910-70', 'O563077010-70', 'O563077110-07', 'O563077611-70', 'O563077810-07', 'O563079110-07', 'O563079320-07', 'O563079610-70', 'O563079710-07', 'O563080010-07', 'O563080310-07', 'O563080410-70', 'O563080420-70', 'O563080510-07', 'O563081410-07', 'O563081610-07', 'O563083010-07', 'O563083110-07', 'O563083210-07', 'O563083220-07', 'O563083310-07', 'O563083710-07', 'O563088090-07', 'O563088110-07', 'O563088210-07', 'O563759210-70', '129820000000')
GROUP BY ArtikelID, Artikel.ArtikelNr, Artikelbezeichnung;

/* UPDATE OPBestand SET OPBestand.inProd = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status BETWEEN 'A' AND 'N'
    AND TIMESTAMPDIFF(SQL_TSI_MONTH, OPTeile.LastScanTime, NOW()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID; */

UPDATE OPBestand SET OPBestand.Qualitaetskontrolle = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status BETWEEN 'D' AND 'I'
    AND TIMESTAMPDIFF(SQL_TSI_MONTH, OPTeile.LastScanTime, NOW()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET OPBestand.EingangUnrein = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status = 'C'
    AND TIMESTAMPDIFF(SQL_TSI_MONTH, OPTeile.LastScanTime, NOW()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
    AND OPTeile.ZielNrID = 300
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

/* UPDATE OPBestand SET OPBestand.Gepackt = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status BETWEEN 'J' AND 'N'
    AND TIMESTAMPDIFF(SQL_TSI_MONTH, OPTeile.LastScanTime, NOW()) <= 6 --nur Teile mit letztem Scan innerhalb der letzten 6 Monate
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID; */

UPDATE OPBestand SET OPBestand.Schrott20Tage = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status = 'Z'
    AND CURDATE() - IFNULL(OPTeile.WegDatum, CONVERT('01.01.1980', SQL_DATE)) <= 20
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET OPBestand.Neu20Tage = x.AnzTeile
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPTeile.ArtikelID, COUNT(OPTeile.ID) AS AnzTeile
  FROM OPTeile
  WHERE OPTeile.Status < 'Z'
    AND OPTeile.Erstwoche IN (SELECT Week.Woche FROM Week WHERE (Week.VonDat <= CURDATE() - 20 AND Week.BisDat >= CURDATE() - 20) OR (Week.VonDat <= CURDATE() AND Week.BisDat >= CURDATE())) 
    AND TIMESTAMPDIFF(SQL_TSI_DAY, OPTeile.Anlage_, NOW()) <= 7
    AND OPTeile.ArtikelID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPTeile.ArtikelID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

/* UPDATE OPBestand SET OPBestand.Angefordert = x.Angefordert
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPSets.Artikel1ID AS ArtikelID, SUM(AnfPo.Angefordert * OPSets.Menge) AS Angefordert
  FROM KdArti, OPSets, (
    SELECT AnfPo.*
    FROM AnfPo, AnfKo
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND IIF(DAYOFWEEK(CURDATE()) <= 5, AnfKo.LieferDatum = CURDATE() + 1, AnfKo.LieferDatum BETWEEN CURDATE() + 1 AND CURDATE() + 3)
      AND AnfKo.Status >= 'F'
      AND AnfKo.Lieferdatum > CURDATE()
  ) AS AnfPo
  WHERE AnfPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = OPSets.ArtikelID
    AND OPSets.Artikel1ID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPSets.Artikel1ID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID; */

/* UPDATE #TmpOPBestand SET AbweichungAnfQK = Qualitaetskontrolle - Angefordert; */

UPDATE OPBestand SET OPBestand.FehlmengeVortag = x.Fehlmenge
FROM #TmpOPBestand AS OPBestand, (
  SELECT OPSets.Artikel1ID AS ArtikelID, SUM((AnfPo.Angefordert - AnfPo.Geliefert) * OPSets.Menge) AS Fehlmenge
  FROM KdArti, OPSets, (
    SELECT AnfPo.*
    FROM AnfPo, AnfKo
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND IIF(DAYOFWEEK(CURDATE()) <= 5, AnfKo.LieferDatum = CURDATE() + 1, AnfKo.LieferDatum BETWEEN CURDATE() + 1 AND CURDATE() + 3)
      AND AnfKo.Status >= 'F'
      AND AnfKo.Lieferdatum > CURDATE()
      AND AnfPo.Geliefert < AnfPo.Angefordert
  ) AS AnfPo
  WHERE AnfPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = OPSets.ArtikelID
    AND OPSets.Artikel1ID IN (SELECT ArtikelID FROM #TmpOPBestand)
  GROUP BY OPSets.Artikel1ID
) AS x
WHERE x.ArtikelID = OPBestand.ArtikelID;

UPDATE OPBestand SET LiefermengeSchnitt = LTData.LiefermengeInhalt / @SchnittWochen / 2 -- 1/2 Durchschnittsliefermenge der letzten x Wochen für den jeweiligen Liefertag
FROM #TmpOPBestand AS OPBestand, (
  SELECT SUM(Ls.Liefermenge * OPSets.Menge) AS LiefermengeInhalt, OPSets.Artikel1ID AS ArtikelIDInhalt
  FROM OPSets, (
    SELECT KdArti.ArtikelID, SUM(LsPo.Menge) AS Liefermenge, DAYOFWEEK(LsKo.Datum) AS Wochentag
    FROM LsPo, LsKo, KdArti
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.KdArtiID = KdArti.ID
      AND LsKo.Datum BETWEEN @LsSchnittVon AND CURDATE()
      AND KdArti.ArtikelID IN (SELECT OPSets.ArtikelID FROM OPSets, #TmpOPBestand OPBestand WHERE OPSets.Artikel1ID = OPBestand.ArtikelID)
    GROUP BY KdArti.ArtikelID, Wochentag
  ) AS Ls
  WHERE Ls.ArtikelID = OPSets.ArtikelID
    AND IIF(DAYOFWEEK(CURDATE()) <= 5, Ls.Wochentag = DAYOFWEEK(CURDATE() + 1), Ls.Wochentag IN (7, 2))
  GROUP BY ArtikelIDInhalt
) AS LTData
WHERE LTData.ArtikelIDInhalt = OPBestand.ArtikelID;

SELECT ArtikelNr, Artikelbezeichnung, LiefermengeSchnitt AS [1/2 Durchschnittsliefermenge], Qualitaetskontrolle, LiefermengeSchnitt - Qualitaetskontrolle AS [Abweichung 1/2 Durchschnittsliefermenge - Qualitaetskontrolle], EingangUnrein AS [Voraviso Unrein], Umlaufmenge, Schrott20Tage AS [Schrott letzte 20 Tage], Neu20Tage AS [Neu letzte 20 Tage], FehlmengeVortag /*,inProd AS [in Produktion], , Angefordert, Gepackt, IIF(Angefordert - Gepackt < 0, 0, Angefordert - Gepackt) AS Benoetigt, AbweichungAnfQK AS [Abweichung Angefordert - Kontrolliert] */ -- Spalten ausgeblendet, dadurch nicht mehr benötigte Update-Statements ebenfalls auskommentiert
FROM #TmpOPBestand x;