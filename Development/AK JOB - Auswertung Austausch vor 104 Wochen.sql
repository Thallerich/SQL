DECLARE @von date, @bis date;

SET @von = N'2023-01-01';
SET @bis = N'2023-03-31';

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Barcode, EinzHist.AusdienstDat, Einsatz.EinsatzBez AS Austauschgrund, EinzHist.Indienst, EinzHist.Ausdienst, DATEDIFF(week, IndienstWoche.VonDat, AusdienstWoche.VonDat) AS [Einsatzdauer in Wochen], Produktion.SuchCode AS Produktionsstandort,
  [Verrechnung] = CASE WHEN EXISTS (
      SELECT TeilSoFa.ID
      FROM TeilSoFa
      WHERE TeilSoFa.EinzHistID = EinzHist.ID
        AND TeilSoFa.SoFaArt = N'R'
        AND (TeilSoFa.RechPoID > 0 OR TeilSoFa.Status IN (N'L', N'P'))
  ) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END
FROM EinzHist
JOIN Einsatz ON EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
JOIN [Week] IndienstWoche ON EinzHist.Indienst = IndienstWoche.Woche
JOIN [Week] AusdienstWoche ON EinzHist.Ausdienst = AusdienstWoche.Woche
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort Produktion ON StandBer.ProduktionID = Produktion.ID
WHERE EinzHist.PoolFkt = 0
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.AusdienstGrund IN (N'A', N'a', N'B', N'b', N'C', N'c', N'E', N'e')
  AND EinzHist.AusdienstDat BETWEEN @von AND @bis
  AND DATEDIFF(week, IndienstWoche.VonDat, AusdienstWoche.VonDat) < 104
  AND Bereich.Bereich = N'BK'
  AND Lagerart.Neuwertig = 1
  AND Kunden.FirmaID = 5260;