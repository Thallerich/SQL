/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Auswertung der JOB-Kunden, die in Klagenfurt produziert werden, inklusive deren Artikel und der Liefermenge               ++ */
/* ++    der letzten 13 Wochen                                                                                                  ++ */
/* ++ Author: Stefan Thaller - 2020-10-09                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KDARTI')
),
Liefermenge AS (
  SELECT LsKo.VsaID, LsPo.KdArtiID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum >= DATEADD(week, -13, GETDATE())
    AND LsKo.Status >= N'Q'
    AND LsPo.ProduktionID IN (
      SELECT Standort.ID
      FROM Standort
      WHERE Standort.SuchCode LIKE N'UKL%'
    )
  GROUP BY LsKo.VsaID, LsPo.KdArtiID
),
ArtiStanGraz AS (
  SELECT ArtiStan.ArtikelID, FaltProg.Programm AS FaltprogNr, FaltProg.FaltProgBez, FinishPr.Programm AS FinishPrNr, FinishPr.FinishPrBez
  FROM ArtiStan
  JOIN FaltProg ON ArtiStan.FaltProgID = FaltProg.ID
  JOIN FinishPr ON ArtiStan.FinishPrID = FinishPr.ID
  JOIN Standort ON ArtiStan.StandortID = Standort.ID
  WHERE Standort.SuchCode = N'GRAZ'
)
SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kunden.PLZ,
  Vsa.VsaNr,
  Vsa.Bez AS [Vsa-Bezeichnung],
  StandKon.StandKonBez AS Standortkonfiguration,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  Artikelstatus.StatusBez AS Kundenartikelstatus,
  ArtiStanGraz.FinishPrNr AS FinishprogrammNr,
  ArtiStanGraz.FinishPrBez AS Finishprogramm,
  ArtiStanGraz.FaltProgNr AS FaltprogrammNr,
  ArtiStanGraz.FaltProgBez AS Faltprogramm,
  Bereich.BereichBez AS Produktbereich,
  KdArti.Umlauf AS Umlaufmenge,
  Liefermenge.Liefermenge AS [Liefermenge letzte 13 Wochen],
  Touren = STUFF((
      SELECT DISTINCT N', ' + Touren.Tour
      FROM VsaTour
      JOIN Touren ON VsaTour.TourenID = Touren.ID
      WHERE VsaTour.VsaID = Vsa.ID
        AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      FOR XML PATH (N'')
    ), 1, 2, N'')
FROM KdArti
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Artikelstatus ON KdArti.Status = Artikelstatus.Status
JOIN Liefermenge ON Liefermenge.KdArtiID = KdArti.ID AND Liefermenge.VsaID = Vsa.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN ArtiStanGraz ON ArtiStanGraz.ArtikelID = Artikel.ID
WHERE KdGf.KurzBez = N'JOB'
  AND Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE Bereich.Bereich = N'BK'
      AND KdBer.KundenID = Kunden.ID
  );

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Lageberstände zu obigen Artikeln in Klagenfurt inklusive Entnahmen in den letzten 3 Monaten                               ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2020-10-09                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @UKLUArtikelJOB TABLE (
  ArtikelID int
);

WITH Liefermenge AS (
  SELECT LsKo.VsaID, LsPo.KdArtiID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum >= DATEADD(week, -13, GETDATE())
    AND LsKo.Status >= N'Q'
    AND LsPo.ProduktionID IN (
      SELECT Standort.ID
      FROM Standort
      WHERE Standort.SuchCode LIKE N'UKL%'
    )
  GROUP BY LsKo.VsaID, LsPo.KdArtiID
)
INSERT INTO @UKLUArtikelJOB (ArtikelID)
SELECT DISTINCT Artikel.ID
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Liefermenge ON Liefermenge.KdArtiID = KdArti.ID AND Liefermenge.VsaID = Vsa.ID
WHERE KdGf.KurzBez = N'JOB'
  AND Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE Bereich.Bereich = N'BK'
      AND KdBer.KundenID = Kunden.ID
  );;

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Lagerart.LagerartBez AS Lagerart, Lagerart.Neuwertig, SUM(Bestand.Bestand) AS Lagerbestand, SUM(Bestand.Entnahme07) AS [Entnahmen 2020-07], SUM(Bestand.Entnahme08) AS [Entnahmen 2020-08], SUM(Bestand.Entnahme09) AS [Entnahmen 2020-09], SUM(Bestand.Entnahme07 + Bestand.Entnahme08 + Bestand.Entnahme09) AS [Entnahmen letzte 3 Monate]
FROM Bestand
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
WHERE Artikel.ID IN (
    SELECT ArtikelID FROM @UKLUArtikelJOB
  )
  AND Standort.SuchCode = N'UKLU'
  AND Bestand.Bestand != 0
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Lagerart.LagerartBez, Lagerart.Neuwertig;

GO