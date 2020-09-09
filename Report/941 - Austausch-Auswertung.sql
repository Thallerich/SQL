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
  SELECT Teile.ArtikelID, Vsa.KundenID, Einsatz.EinsatzGrund AS GrundKurz, COUNT(Teile.ID) AS Menge, FORMAT(Teile.AusdienstDat, N'yyyy-MM', N'de-AT') AS Monat
  FROM Teile
  JOIN Einsatz ON Teile.AusdienstGrund = Einsatz.EinsatzGrund
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  WHERE Teile.AusdienstGrund IN (N'A', N'a', N'B', N'b', N'C', N'c')
    AND Teile.AusdienstDat BETWEEN @DatumVon AND @DatumBis
  GROUP BY Teile.ArtikelID, Vsa.KundenID, Einsatz.EinsatzGrund, FORMAT(Teile.AusdienstDat, N'yyyy-MM', N'de-AT')
),
WegTeileSumme AS (
  SELECT Teile.ArtikelID, Vsa.KundenID, COUNT(Teile.ID) AS Menge, SUM(Teile.AusdRestw) AS Restwert, SUM(IIF(Teile.RechPoID > 0, Teile.AusdRestw, 0)) AS RestwertFakt, FORMAT(Teile.AusdienstDat, N'yyyy-MM', N'de-AT') AS Monat
  FROM Teile
  JOIN Einsatz ON Teile.AusdienstGrund = Einsatz.EinsatzGrund
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  WHERE Teile.AusdienstGrund IN (N'A', N'a', N'B', N'b', N'C', N'c')
    AND Teile.AusdienstDat BETWEEN @DatumVon AND @DatumBis
  GROUP BY Teile.ArtikelID, Vsa.KundenID, FORMAT(Teile.AusdienstDat, N'yyyy-MM', N'de-AT')
)
SELECT [Monat], [KdNr], [Kunde], [Haupstandort Kunde], [ArtikelNr], [Artikelbezeichnung], [Umlaufmenge aktuell], [Liefermenge im Zeitraum], [AORW] AS [Austausch ohne RW-Berechnung], [AMRW] AS [Austausch mit RW-Berechnung], [BORW] AS [Größentausch ohne RW-Berechnung], [BMRW] AS [Größentausch mit RW-Berechnung], [CORW] AS [Artikeltausch ohne RW-Berechnung], [CMRW] AS [Artikeltausch mit RW-Berechnung], [MengeGesamt] AS [Anzahl gesamt / Kunde], [Restwert] AS [Restwert Austausch], [RestwertFakt] AS [Restwert verrechnet], [Differenz]
FROM (
  SELECT COALESCE(Liefermenge.Monat, WegTeile.Monat, WegTeileSumme.Monat) AS Monat, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.SuchCode AS [Haupstandort Kunde], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArtiSum.Umlauf AS [Umlaufmenge aktuell], SUM(ISNULL(Liefermenge.Menge, 0)) AS [Liefermenge im Zeitraum], SUM(ISNULL(WegTeile.Menge, 0)) AS MengeWeg, GrundKurz = 
    CASE WegTeile.GrundKurz
      WHEN N'A' THEN N'AORW'
      WHEN N'a' THEN N'AMRW'
      WHEN N'B' THEN N'BORW'
      WHEN N'b' THEN N'BMRW'
      WHEN N'C' THEN N'CORW'
      WHEN N'c' THEN N'CMRW'
    END, WegTeileSumme.Menge AS MengeGesamt, WegTeileSumme.Restwert, WegTeileSumme.RestwertFakt, WegTeileSumme.Restwert - WegTeileSumme.RestwertFakt AS Differenz
  FROM (
    SELECT KdArti.ArtikelID, KdArti.KundenID, SUM(KdArti.Umlauf) AS Umlauf
    FROM KdArti
    GROUP BY KdArti.ArtikelID, KdArti.KundenID
  ) AS KdArtiSum
  JOIN Kunden ON KdArtiSum.KundenID = Kunden.ID
  JOIN Artikel ON KdArtiSum.ArtikelID = Artikel.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  LEFT OUTER JOIN Liefermenge ON Liefermenge.ArtikelID = KdArtiSum.ArtikelID AND Liefermenge.KundenID = KdArtiSum.KundenID
  LEFT OUTER JOIN WegTeile ON WegTeile.ArtikelID = KdArtiSum.ArtikelID AND WegTeile.KundenID = KdArtiSum.KundenID
  LEFT OUTER JOIN WegTeileSumme ON WegTeileSumme.ArtikelID = KdArtiSum.ArtikelID AND WegTeileSumme.KundenID = KdArtiSum.KundenID
  WHERE Kunden.KdGFID IN ($3$)
    AND Kunden.FirmaID IN ($2$)
    AND Kunden.StandortID IN ($4$)
    AND Kunden.SichtbarID IN ($SICHTBARIDS$)
    AND KdArtiSum.Umlauf > 0
    AND EXISTS (
      SELECT Teile.*
      FROM Teile
      WHERE Teile.ArtikelID = KdArtiSum.ArtikelID
        AND Teile.AltenheimModus = 0
    )
    AND (Liefermenge.Menge != 0 OR WegTeile.Menge != 0 OR WegTeileSumme.Menge != 0)
  GROUP BY COALESCE(Liefermenge.Monat, WegTeile.Monat, WegTeileSumme.Monat), Kunden.KdNr, Kunden.SuchCode, Standort.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArtiSum.Umlauf, WegTeile.GrundKurz, WegTeileSumme.Menge, WegTeileSumme.Restwert, WegTeileSumme.RestwertFakt
) AS AData
PIVOT (
  SUM(MengeWeg) FOR GrundKurz IN ([AORW], [AMRW], [BORW], [BMRW], [CORW], [CMRW], [-])
) AS p
ORDER BY Monat, KdNr, ArtikelNr;