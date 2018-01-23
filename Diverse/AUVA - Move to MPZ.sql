DROP TABLE IF EXISTS #TmpLSChange
GO

DECLARE @Mapping TABLE (KdNr int, KdNrNeu int)

INSERT INTO @Mapping VALUES
  (2523283, 31063),
  (2523284, 31064),
  (2523285, 31065),
  (2523298, 31066)

SELECT Kunden.KdNr AS KdNrAlt, LsKo.LsNr, LsPo.ID AS LsPoID, LsKo.ID AS LsKoID, Vsa.VsaNr, LsKo.VsaID, -1 AS VsaNeuID, Abteil.Abteilung, LsPo.AbteilID, -1 AS AbteilNeuID, KdArti.ArtikelID, KdArti.Variante, LsPo.KdArtiID, -1 AS KdArtiNeuID, VsaOrt.Folge, VsaOrt.Bez, LsPo.VsaOrtID, -1 AS VsaOrtNeuID, LsPo.RechPoID, LsKo.Status, LsKo.Datum, LsPo.EPreis
INTO #TmpLSChange
FROM LsPo, LsKo, Abteil, Vsa, Kunden, KdArti, VsaOrt, @Mapping AS Mapping
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND LsPo.AbteilID = Abteil.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND LsPo.VsaOrtID = VsaOrt.ID
  AND Kunden.KdNr = Mapping.KdNr
  AND LsKo.Datum >= N'2017-11-01' --BETWEEN N'2017-07-01' AND N'2017-10-31'
  AND LsKo.Status = N'Q'

UPDATE #TmpLSChange SET VsaNeuID = x.VsaIDNeu
FROM (
  SELECT DISTINCT LsChange.VsaID, Vsa.ID AS VsaIDNeu
  FROM #TmpLSChange AS LSChange, @Mapping AS Mapping, Vsa, Kunden
  WHERE LSChange.KdNrAlt = Mapping.KdNr
    AND Mapping.KdNrNeu = Kunden.KdNr
    AND Vsa.KundenID = Kunden.ID
    AND Vsa.VsaNr = LSChange.VsaNr
) AS x
WHERE x.VsaID = #TmpLSChange.VsaID

UPDATE #TmpLSChange SET AbteilNeuID = x.AbteilIDNeu
FROM (
  SELECT DISTINCT LSChange.AbteilID, Abteil.ID AS AbteilIDNeu
  FROM #TmpLSChange AS LSChange, @Mapping AS Mapping, Abteil, Kunden
  WHERE LSChange.KdNrAlt = Mapping.KdNr
    AND Mapping.KdNrNeu = Kunden.KdNr
    AND Abteil.KundenID = Kunden.ID
    AND Abteil.Abteilung = LSChange.Abteilung
) AS x
WHERE x.AbteilID = #TmpLSChange.AbteilID

UPDATE #TmpLSChange SET KdArtiNeuID = x.KdArtiIDNeu
FROM (
  SELECT DISTINCT LSChange.KdArtiID, LSChange.Variante, KdArti.ID AS KdArtiIDNeu
  FROM #TmpLSChange AS LSChange, @Mapping AS Mapping, KdArti, Kunden
  WHERE LSChange.KdNrAlt = Mapping.KdNr
    AND Mapping.KdNrNeu = Kunden.KdNr
    AND KdArti.KundenID = Kunden.ID
    AND KdArti.ArtikelID = LSChange.ArtikelID
    AND KdArti.Variante = LSChange.Variante
) AS x
WHERE x.KdArtiID = #TmpLSChange.KdArtiID AND x.Variante = #TmpLSChange.Variante

UPDATE #TmpLSChange SET VsaOrtNeuID = x.VsaOrtIDNeu
FROM (
  SELECT DISTINCT LSChange.VsaOrtID, LSChange.Folge, LSChange.Bez, VsaOrt.ID AS VsaOrtIDNeu
  FROM #TmpLSChange AS LSChange, @Mapping AS Mapping, VsaOrt, Vsa, Kunden
  WHERE LSChange.KdNrAlt = Mapping.KdNr
    AND Mapping.KdNrNeu = Kunden.KdNr
    AND Vsa.KundenID = Kunden.ID
    AND VsaOrt.VsaID = Vsa.ID
    AND VsaOrt.Folge = LSChange.Folge
    AND VsaOrt.Bez = LSChange.Bez
    AND Vsa.VsaNr = LSChange.VsaNr
) AS x
WHERE x.VsaOrtID = #TmpLSChange.VsaOrtID AND x.Folge = #TmpLSChange.Folge AND x.Bez = #TmpLSChange.Bez

UPDATE LsKo SET LsKo.VsaID = x.VsaNeuID, LsKo.Status = N'Q'
FROM (SELECT DISTINCT LsKoID, VsaNeuID FROM #TmpLSChange) AS x
WHERE x.LsKoID = LsKo.ID

UPDATE LsPo SET LsPo.AbteilID = x.AbteilNeuID, LsPo.KdArtiID = x.KdArtiNeuID, LsPo.VsaOrtID = x.VsaOrtNeuID, LsPo.RechPoID = IIF(LsPo.RechPoID < -1, -4, -1)
FROM #TmpLSChange AS x
WHERE x.LsPoID = LsPo.ID

GO

/*
SELECT AbtKdArW.Monat, Wochen.Woche, AbtKdArW.Menge, AbtKdArW.EPreis, AbtKdArW.WoPa, Artikel.ArtikelNr, Artikel.ArtikelBez, Vsa.Bez AS Vsa
FROM AbtKdArW, Vsa, Kunden, Wochen, KdArti, Artikel
WHERE AbtKdArW.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AbtKdArW.WochenID = Wochen.ID
  AND AbtKdArW.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.KdNr = 31063
  AND AbtKdArW.Monat IN (N'2017-07')
  AND AbtKdArW.EPreis > 0

UPDATE AbtKdArW SET RechPoID = -1 
WHERE ID IN (
  SELECT AbtKdArW.ID
  FROM AbtKdArW, Vsa, Kunden, Wochen, KdArti, Artikel
  WHERE AbtKdArW.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND AbtKdArW.WochenID = Wochen.ID
    AND AbtKdArW.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Kunden.KdNr = 2523283
    AND AbtKdArW.Monat IN (N'2017-07', N'2017-08', N'2017-09', N'2017-10')
    AND AbtKdArW.RechPoID > 0
)
*/

/*
UPDATE RechKo SET Status = N'A', DrLaufID = 5104, ZahlZielID = 6, WaeID = 4, VonDatum = NULL, BisDatum = NULL, DruckDatum = NULL, FaelligDat = NULL, MailDatum = NULL, PlanAbbuchDat = NULL, EffektivBis = NULL, FreigabeZeit = NULL, BeglichenAm = NULL, Mahnstufe1Seit = NULL, Mahnstufe2Seit = NULL, Mahnstufe3Seit = NULL, Mahnstufe4Seit = NULL, Mahnstufe5Seit = NULL, SEPADateiEinreichung = NULL, DruckZeitpunkt = NULL
WHERE RechKo.RechNr <= -10890000
  AND RechKo.KundenID = (SELECT ID FROM Kunden WHERE KdNr = 31065)

SELECT * FROM RechKo WHERE RechNr IN(677909, -10890002)


DECLARE @Mapping TABLE (KdNr int, KdNrNeu int)

INSERT INTO @Mapping VALUES
  (2523283, 31063),
  (2523284, 31064),
  (2523285, 31065),
  (2523298, 31066)

SELECT RKoNeu.KdNrNeu, RKoNeu.RechNr AS RechNrNeu, RKoNeu.NettoWert AS NettoNeu, RKoNeu.BruttoWert AS BruttoNeu, RKoAlt.KdNr AS KdNrAlt, RKoAlt.RechNr AS RechNrAlt, RKoAlt.NettoWert AS NettoAlt, RKoAlt.BruttoWert AS BruttoAlt, RkoAlt.RechDat, RKoNeu.RechDat
FROM (
  SELECT Mapping.KdNrNeu, Mapping.KdNr, RechKo.*
  FROM RechKo
  JOIN Kunden ON RechKo.KundenID = Kunden.ID 
  JOIN @Mapping AS Mapping ON Kunden.KdNr = Mapping.KdNr
  WHERE RechKo.RechDat >= N'2017-07-31'
    AND RechKo.NettoWert <> 0
) AS RKoAlt
LEFT OUTER JOIN (
  SELECT Mapping.KdNrNeu, RechKo.*
  FROM RechKo
  JOIN Kunden ON RechKo.KundenID = Kunden.ID 
  JOIN @Mapping AS Mapping ON Kunden.KdNr = Mapping.KdNrNeu
) AS RKoNeu ON RKoNeu.KdNrNeu = RKoAlt.KdNrNeu AND RKoNeu.NettoWert = RKoAlt.NettoWert AND RKoNeu.RechDat = RKoAlt.RechDat

GO
*/