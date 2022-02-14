DROP TABLE IF EXISTS #InKalkLsKo;
DROP TABLE IF EXISTS #ApplyInKalk;

GO

DECLARE @VonDat date = N'2022-02-07';
DECLARE @BisDat date = N'2022-02-13';
DECLARE @MinPrio int = (SELECT MIN(Prio) FROM InKalk);
DECLARE @MaxPrio int = (SELECT MAX(Prio) FROM InKalk);
DECLARE @CurrPrio int;

SET NOCOUNT ON;

SELECT ID, VsaID, FahrtID, Datum, ProduktionID, LsKoArtID
INTO #InKalkLsKo
FROM LsKo
WHERE LsKo.Datum BETWEEN @VonDat AND @BisDat
  AND LsKo.STATUS >= N'Q'
  AND EXISTS (
    SELECT LsPo.ID
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.Menge != 0
  );

SELECT LsPo.ID LsPoID, Kunden.ID KundenID, KdArti.ArtikelID, Kunden.FirmaID, Fahrt.ExpeditionID, LsKo.ProduktionID, Kunden.VertragWaeID WaeID, Artikel.BereichID, Firma.WaeID FirmaWaeID, LsKo.Datum, CAST(1.00 AS FLOAT) WaeFaktor,
  CASE
    WHEN LsKo.LsKoArtID IN (
      SELECT LsKoArt.ID
      FROM LsKoArt
      WHERE IstLagerVerkauf = 1
    ) THEN 'V'
    WHEN (KdArti.WaschPreis <> 0.0) AND (KdArti.LeasPreis <> 0.0) THEN 'S'
    WHEN KdArti.WaschPreis <> 0.0 THEN 'W'
    WHEN KdArti.LeasPreis <> 0.0 THEN 'L'
    WHEN (KdArti.WaschPreis = 0.0) AND (KdArti.LeasPreis = 0.0) THEN 'L' -- 2019-12-17: wenn Waschpreis = 0 und Leasingpreis = 0 die Position wie einen Leasingartikel (Art = L) behandeln
    ELSE '?'
  END Art, -999 InKalkID, -999 Prio
INTO #ApplyInKalk
FROM #InKalkLsKo LsKo, LsPo, Vsa, Kunden, KdArti, Fahrt, Artikel, Firma
WHERE LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND LsKo.FahrtID = Fahrt.ID
  AND LsPo.LsKoID = LsKo.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.FirmaID = Firma.ID
  AND LsPo.Kostenlos = 0
  AND ((LsPo.Menge > 0 AND LsKo.Datum BETWEEN @VonDat AND @BisDat) OR (LsPo.Menge < 0 AND LsKo.Datum BETWEEN DateAdd(Month, - 3, @VonDat) AND @BisDat));

SET @CurrPrio = @MinPrio;

WHILE (@CurrPrio <= @MaxPrio)
BEGIN
  UPDATE #ApplyInKalk
  SET InKalkID = InKalk.ID, Prio = @CurrPrio
  FROM InKalk
  WHERE IIF(InKalk.ArtikelID = - 1, #ApplyInKalk.ArtikelID, InKalk.ArtikelID) = #ApplyInKalk.ArtikelID
    AND IIF(InKalk.KundenID = - 1, #ApplyInKalk.KundenID, InKalk.KundenID) = #ApplyInKalk.KundenID
    AND IIF(InKalk.ProduktionID = - 1, #ApplyInKalk.ProduktionID, InKalk.ProduktionID) = #ApplyInKalk.ProduktionID
    AND IIF(InKalk.FirmaID = - 1, #ApplyInKalk.FirmaID, InKalk.FirmaID) = #ApplyInKalk.FirmaID
    AND IIF(InKalk.BereichID = - 1, #ApplyInKalk.BereichID, InKalk.BereichID) = #ApplyInKalk.BereichID
    AND IIF(InKalk.WaeID = - 2, #ApplyInKalk.WaeID, InKalk.WaeID) = #ApplyInKalk.WaeID
    AND InKalk.Prio = @CurrPrio
    AND #ApplyInKalk.Prio = - 999;

  SET @CurrPrio = @CurrPrio + 1;
END

-- ermitteln, wie viel 1,00 Lieferschein-Währung in Firmen-Währung ist
UPDATE #ApplyInKalk
SET #ApplyInKalk.WaeFaktor = x.EffektiverKurs
FROM Wae, Wae FirmaWae, #ApplyInKalk
CROSS APPLY dbo.advFunc_ConvertExchangeRate(#ApplyInKalk.WaeID, #ApplyInKalk.FirmaWaeID, 1.00, #ApplyInKalk.Datum) x
WHERE #ApplyInKalk.WaeID = Wae.ID
  AND #ApplyInKalk.FirmaWaeID = FirmaWae.ID
  AND Wae.IsoCode <> FirmaWae.IsoCode;

SELECT LsKo.ID AS LsKoID, LsKo.LsNr, LsKo.Datum AS Lieferdatum, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Produktion.SuchCode AS Produktion, Expedition.SuchCode AS Expedition, Bereich.Bereich AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.WaschPreis, KdArti.LeasPreis, LsPo.EPreis, LsPo.Menge, LsPo.InternKalkPreis,
  [InternKalkPreis berechnet] = CAST(
    CASE
      WHEN Art = 'W' THEN IIF(InKalk.InKalkWaschPreis <> 0, InKalk.InKalkWaschPreis, (InKalk.InKalkWaschProzent / 100) * LsPo.EPreis * WaeFaktor)
      WHEN Art = 'S' THEN (InKalk.InKalkSplitProzent / 100) * LsPo.EPreis * WaeFaktor
      WHEN Art = 'L' THEN IIF(InKalk.InKalkLeasPreis <> 0, InKalk.InKalkLeasPreis, ISNULL(LeasPreisProWo.LeasPreisProWo, 0.0) * (InKalk.InKalkLeasProzent / 100) * InKalk.InKalkPreisfaktor * WaeFaktor)
      WHEN Art = 'V' THEN IIF(InKalk.InKalkWaschPreis <> 0, InKalk.InKalkWaschPreis, (InKalk.InKalkWaschProzent / 100) * LsPo.EPreis * WaeFaktor)
      ELSE 0.0
    END AS money),
  LsKo.InternKalkFix, LsKo.SentToSAP, LsPo.Update_ AS LsPoUpdate, KdArti.ID AS KdArtiID
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort AS Produktion ON LsPo.ProduktionID = Produktion.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Standort AS Expedition ON Fahrt.ExpeditionID = Expedition.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN #ApplyInKalk AS ApplyInKalk ON ApplyInKalk.LsPoID = LsPo.ID
JOIN InKalk ON ApplyInKalk.InKalkID = InKalk.ID
LEFT JOIN dbo.advFunc_GetLeasPreisProWo(- 999) LeasPreisProWo ON KdArti.ID = LeasPreisProWo.KdArtiID
WHERE LsPo.InternKalkPreis != CAST(CASE
      WHEN Art = 'W' THEN IIF(InKalk.InKalkWaschPreis <> 0, InKalk.InKalkWaschPreis, (InKalk.InKalkWaschProzent / 100) * LsPo.EPreis * WaeFaktor)
      WHEN Art = 'S' THEN (InKalk.InKalkSplitProzent / 100) * LsPo.EPreis * WaeFaktor
      WHEN Art = 'L' THEN IIF(InKalk.InKalkLeasPreis <> 0, InKalk.InKalkLeasPreis, ISNULL(LeasPreisProWo.LeasPreisProWo, 0.0) * (InKalk.InKalkLeasProzent / 100) * InKalk.InKalkPreisfaktor * WaeFaktor)
      WHEN Art = 'V' THEN IIF(InKalk.InKalkWaschPreis <> 0, InKalk.InKalkWaschPreis, (InKalk.InKalkWaschProzent / 100) * LsPo.EPreis * WaeFaktor)
      ELSE 0.0
    END AS money)
  AND Produktion.SuchCode != N'BUDA';

GO