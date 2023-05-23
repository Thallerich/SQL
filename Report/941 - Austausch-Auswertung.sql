DECLARE @DatumVon date = $STARTDATE$;
DECLARE @DatumBis date = $ENDDATE$;

WITH Liefermenge AS (
  SELECT KdArti.ArtikelID, KdArti.KundenID, SUM(CAST(LsPo.Menge AS int)) AS Menge, FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT') AS Monat
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  WHERE LsKo.Datum BETWEEN @DatumVon AND @DatumBis
  GROUP BY KdArti.ArtikelID, KdArti.KundenID, FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT')
),
WegTeile AS (
  SELECT EinzHist.ArtikelID, Vsa.KundenID, Einsatz.EinsatzGrund AS GrundKurz, COUNT(EinzHist.ID) AS Menge, FORMAT(EinzHist.AusdienstDat, N'yyyy-MM', N'de-AT') AS Monat
  FROM EinzHist
  JOIN Einsatz ON EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  WHERE EinzHist.AusdienstGrund IN (N'A', N'a', N'B', N'b', N'C', N'c', N'E', N'e')
    AND EinzHist.AusdienstDat BETWEEN @DatumVon AND @DatumBis
  GROUP BY EinzHist.ArtikelID, Vsa.KundenID, Einsatz.EinsatzGrund, FORMAT(EinzHist.AusdienstDat, N'yyyy-MM', N'de-AT')
),
WegTeileSumme AS (
  SELECT x.ArtikelID, x.KundenID, COUNT(x.TeileID) AS Menge, SUM(x.AusdRestw) AS Restwert, SUM(IIF(x.HasRech = 1, x.AusdRestw, 0)) AS RestwertFakt, FORMAT(x.AusdienstDat, N'yyyy-MM', N'de-AT') AS Monat
  FROM (
    SELECT EinzHist.ArtikelID, Vsa.KundenID, EinzHist.ID AS TeileID, EinzHist.AusdRestw, EinzHist.AusdienstDat, HasRech = CAST(ISNULL((
      SELECT 1
      FROM TeilSoFa
      WHERE TeilSoFa.EinzHistID = EinzHist.ID
        AND TeilSoFa.SoFaArt = N'R'
        AND TeilSoFa.RechPoID > 0
    ), 0) AS bit)
    FROM EinzHist
    JOIN Einsatz ON EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
    JOIN Vsa ON EinzHist.VsaID = Vsa.ID
    WHERE EinzHist.AusdienstGrund IN (N'A', N'a', N'B', N'b', N'C', N'c', N'E', N'e')
      AND EinzHist.AusdienstDat BETWEEN @DatumVon AND @DatumBis
  ) x
  GROUP BY x.ArtikelID, x.KundenID, FORMAT(x.AusdienstDat, N'yyyy-MM', N'de-AT')
),
TeileRep AS (
  SELECT EinzHist.ArtikelID, Vsa.KundenID, CAST(SUM(TeilSoFa.Menge) AS int) AS AnzReparatur, FORMAT(TeilSoFa.Zeitpunkt, N'yyyy-MM', N'de-AT') AS Monat
  FROM TeilSoFa
  JOIN Artikel ON TeilSoFa.ArtikelID = Artikel.ID
  JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  WHERE CAST(TeilSoFa.Zeitpunkt AS date) BETWEEN @DatumVon AND @DatumBis
    AND Artikel.ArtiTypeID = 5  --Reparatur-Artikel
  GROUP BY EinzHist.ArtikelID, Vsa.KundenID, FORMAT(TeilSoFa.Zeitpunkt, N'yyyy-MM', N'de-AT')
)
SELECT [Monat], [KdNr], [Kunde], [Haupstandort Kunde], [ArtikelNr], [Artikelbezeichnung], [Umlaufmenge aktuell], [Liefermenge im Zeitraum], [AORW] AS [Austausch ohne RW-Berechnung], [AMRW] AS [Austausch mit RW-Berechnung], [BORW] AS [Größentausch ohne RW-Berechnung], [BMRW] AS [Größentausch mit RW-Berechnung], [CORW] AS [Artikeltausch ohne RW-Berechnung], [CMRW] AS [Artikeltausch mit RW-Berechnung], [SMRW] AS [Austausch Service mit RW-Berechnung], [SORW] AS [Austausch Service ohne RW-Berechnung], [MengeGesamt] AS [Anzahl gesamt / Kunde], [Restwert] AS [Restwert Austausch], [RestwertFakt] AS [Restwert verrechnet], [Differenz], [AnzReparatur]
FROM (
  SELECT COALESCE(Liefermenge.Monat, WegTeile.Monat, WegTeileSumme.Monat) AS Monat, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.SuchCode AS [Haupstandort Kunde], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArtiSum.Umlauf AS [Umlaufmenge aktuell], SUM(ISNULL(Liefermenge.Menge, 0)) AS [Liefermenge im Zeitraum], SUM(ISNULL(WegTeile.Menge, 0)) AS MengeWeg, GrundKurz = 
    CASE WegTeile.GrundKurz
      WHEN N'A' THEN N'AMRW'
      WHEN N'a' THEN N'AORW'
      WHEN N'B' THEN N'BMRW'
      WHEN N'b' THEN N'BORW'
      WHEN N'C' THEN N'CMRW'
      WHEN N'c' THEN N'CORW'
      WHEN N'E' THEN N'SMRW'
      WHEN N'e' THEN N'SORW'
    END, WegTeileSumme.Menge AS MengeGesamt, WegTeileSumme.Restwert, WegTeileSumme.RestwertFakt, WegTeileSumme.Restwert - WegTeileSumme.RestwertFakt AS Differenz, SUM(ISNULL(TeileRep.AnzReparatur, 0)) AS AnzReparatur
  FROM WegTeile
  JOIN (
    SELECT KdArti.ArtikelID, KdArti.KundenID, SUM(KdArti.Umlauf) AS Umlauf
    FROM KdArti
    GROUP BY KdArti.ArtikelID, KdArti.KundenID
  ) AS KdArtiSum ON WegTeile.ArtikelID = KdArtiSum.ArtikelID AND WegTeile.KundenID = KdArtiSum.KundenID
  JOIN Kunden ON KdArtiSum.KundenID = Kunden.ID
  JOIN Artikel ON KdArtiSum.ArtikelID = Artikel.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN WegTeileSumme ON WegTeileSumme.ArtikelID = KdArtiSum.ArtikelID AND WegTeileSumme.KundenID = KdArtiSum.KundenID AND WegTeileSumme.Monat = WegTeile.Monat
  LEFT JOIN Liefermenge ON Liefermenge.ArtikelID = KdArtiSum.ArtikelID AND Liefermenge.KundenID = KdArtiSum.KundenID AND Liefermenge.Monat = WegTeile.Monat
  LEFT JOIN TeileRep ON WegTeile.ArtikelID = TeileRep.ArtikelID AND WegTeile.KundenID = TeileRep.KundenID AND WegTeile.Monat = TeileRep.Monat
  WHERE Kunden.KdGFID IN ($3$)
    AND Kunden.FirmaID IN ($2$)
    AND Kunden.StandortID IN ($4$)
    AND Kunden.SichtbarID IN ($SICHTBARIDS$)
    AND KdArtiSum.Umlauf > 0
    AND EXISTS (
      SELECT EinzHist.*
      FROM EinzHist
      JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
      WHERE EinzHist.ArtikelID = KdArtiSum.ArtikelID
        AND EinzTeil.AltenheimModus = 0
    )
    AND (Liefermenge.Menge != 0 OR WegTeile.Menge != 0 OR WegTeileSumme.Menge != 0)
  GROUP BY COALESCE(Liefermenge.Monat, WegTeile.Monat, WegTeileSumme.Monat), Kunden.KdNr, Kunden.SuchCode, Standort.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArtiSum.Umlauf, WegTeile.GrundKurz, WegTeileSumme.Menge, WegTeileSumme.Restwert, WegTeileSumme.RestwertFakt
) AS AData
PIVOT (
  SUM(MengeWeg) FOR GrundKurz IN ([AORW], [AMRW], [BORW], [BMRW], [CORW], [CMRW], [SMRW], [SORW], [-])
) AS p
ORDER BY Monat, KdNr, ArtikelNr;