/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: VSA-Lieferpause                                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @currentweek nchar(7);

SELECT @currentweek = [Week].Woche
FROM [Week]
WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat;

SELECT Standort.Bez AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], WegGrund.WeggrundBez$LAN$ AS [Lieferpausen-Grund], VsaPause.VonDatum AS [Lieferpause von], VsaPause.BisDatum AS [Lieferpause bis], VsaPause.VonWoche AS [Lieferpause ab KW], VsaPause.BisWoche AS [Lieferpause bis KW]
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN VsaPause ON VsaPause.VsaID = Vsa.ID
JOIN WegGrund ON VsaPause.PauseGrundID = WegGrund.ID
WHERE VsaPause.KdArtiID < 0
  AND VsaPause.TraegerID < 0
  AND (VsaPause.BisDatum >= CAST(GETDATE() AS date) OR VsaPause.BisWoche >= @CurrentWeek)
  AND VsaPause.IsLieferpause = 1
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.ID IN ($2$)
  AND VsaPause.PauseGrundID IN ($3$)
ORDER BY Hauptstandort, KdNr, VsaNr;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Anforderbare Artikel                                                                                            ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH Liefertag AS (
  SELECT VsaID, KdBerID, [1] AS Montag, [2] AS Dienstag, [3] AS Mittwoch, [4] AS Donnerstag, [5] AS Freitag, [6] AS Samstag, [7] AS Sonntag
  FROM (
    SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Wochentag, N'X' AS LiefertagExists
    FROM VsaTour
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    WHERE CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND VsaTour.Bringen = 1
  ) TourTage
  PIVOT (MAX(LiefertagExists) FOR Wochentag IN ([1], [2], [3], [4], [5], [6], [7])) AS pivotresult
)
SELECT Standort.Bez AS Hauptstandort,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.ID AS VsaID,
  Vsa.VsaNr,
  Vsa.SuchCode AS [Vsa-Stichwort],
  Vsa.Bez AS [Vsa-Bezeichnung],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  KdArti.Variante,
  VsaAnf.Bestand AS Vertragsbestand,
  IIF(VsaAnf.Art = N'F' AND Liefertag.Montag = N'X', TRY_CAST(VsaAnf.Liefern1 AS int), NULL) AS [feste Liefermenge Montag],
  IIF(VsaAnf.Art = N'F' AND Liefertag.Dienstag = N'X', TRY_CAST(VsaAnf.Liefern2 AS int), NULL) AS [feste Liefermenge Dienstag],
  IIF(VsaAnf.Art = N'F' AND Liefertag.Mittwoch = N'X', TRY_CAST(VsaAnf.Liefern3 AS int), NULL) AS [feste Liefermenge Mittwoch],
  IIF(VsaAnf.Art = N'F' AND Liefertag.Donnerstag = N'X', TRY_CAST(VsaAnf.Liefern4 AS int), NULL) AS [feste Liefermenge Donnerstag],
  IIF(VsaAnf.Art = N'F' AND Liefertag.Freitag = N'X', TRY_CAST(VsaAnf.Liefern5 AS int), NULL) AS [feste Liefermenge Freitag],
  IIF(VsaAnf.Art = N'F' AND Liefertag.Samstag = N'X', TRY_CAST(VsaAnf.Liefern6 AS int), NULL) AS [feste Liefermenge Samstag],
  IIF(VsaAnf.Art = N'F' AND Liefertag.Sonntag = N'X', TRY_CAST(VsaAnf.Liefern7 AS int), NULL) AS [feste Liefermenge Sonntag],
  IIF(VsaAnf.Art = N'N', TRY_CAST(VsaAnf.NormMenge AS int), NULL) AS [Norm-Liefermenge],
  VsaAnf.Ungueltig AS [Pause von],
  VsaAnf.UngueltigBis AS [Pause bis]
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN Liefertag ON Liefertag.VsaID = Vsa.ID AND Liefertag.KdBerID = KdArti.KdBerID
WHERE VsaAnf.[Status] IN (N'A', N'C')
  AND VsaAnf.UngueltigBis > CAST(GETDATE() AS date)
  AND Vsa.[Status] = N'A'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.ID IN ($2$);