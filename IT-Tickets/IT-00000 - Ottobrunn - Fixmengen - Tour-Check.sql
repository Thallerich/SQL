WITH TourLT AS (
  SELECT TourPivot.VsaID, TourPivot.KdBerID, CAST(IIF([1] IS NOT NULL, 1, 0) AS bit) AS MontagTour, CAST(IIF([2] IS NOT NULL, 1, 0) AS bit) AS DienstagTour, CAST(IIF([3] IS NOT NULL, 1, 0) AS bit) AS MittwochTour, CAST(IIF([4] IS NOT NULL, 1, 0) AS bit) AS DonnerstagTour, CAST(IIF([5] IS NOT NULL, 1, 0) AS bit) AS FreitagTour, CAST(IIF([6] IS NOT NULL, 1, 0) AS bit) AS SamstagTour, CAST(IIF([7] IS NOT NULL, 1, 0) AS bit) AS SonntagTour
  FROM (
    SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Wochentag
    FROM VsaTour
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    JOIN Vsa ON VsaTour.VsaID = Vsa.ID
    JOIN Kunden ON Vsa.KundenID = Kunden.ID
    WHERE Kunden.KdNr IN (
        SELECT DISTINCT _FixmengenOtto.KdNr
        FROM Salesianer.dbo._FixmengenOtto
      )
      AND VsaTour.Bringen = 1
      AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
  ) TourPivotData
  PIVOT (
    MAX(Wochentag) FOR Wochentag IN ([1], [2], [3], [4], [5], [6], [7])
  ) TourPivot
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, CAST(IIF(VsaAnf.Liefern1 != 0, 1, 0) AS bit) AS LTMontag, CAST(IIF(VsaAnf.Liefern2 != 0, 1, 0) AS bit) AS LTDienstag, CAST(IIF(VsaAnf.Liefern3 != 0, 1, 0) AS bit) AS LTMittwoch, CAST(IIF(VsaAnf.Liefern4 != 0, 1, 0) AS bit) AS LTDonnerstag, CAST(IIF(VsaAnf.Liefern5 != 0, 1, 0) AS bit) AS LTFreitag, CAST(IIF(VsaAnf.Liefern6 != 0, 1, 0) AS bit) AS LTSamstag, CAST(IIF(VsaAnf.Liefern7 != 0, 1, 0) AS bit) AS LTSonntag
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
LEFT JOIN TourLT ON TourLT.VsaID = Vsa.ID AND TourLT.KdBerID = KdArti.KdBerID
WHERE Kunden.KdNr IN (
    SELECT DISTINCT _FixmengenOtto.KdNr
    FROM Salesianer.dbo._FixmengenOtto
  )
  AND VsaAnf.Status = N'A'
  AND VsaAnf.Art NOT IN (N'm', N'M')
  AND (
       (VsaAnf.Liefern1 != 0 AND TourLT.MontagTour = 0)
    OR (VsaAnf.Liefern2 != 0 AND TourLT.DienstagTour = 0)
    OR (VsaAnf.Liefern3 != 0 AND TourLT.MittwochTour = 0)
    OR (VsaAnf.Liefern4 != 0 AND TourLT.DonnerstagTour = 0)
    OR (VsaAnf.Liefern5 != 0 AND TourLT.FreitagTour = 0)
    OR (VsaAnf.Liefern6 != 0 AND TourLT.SamstagTour = 0)
    OR (VsaAnf.Liefern7 != 0 AND TourLT.SonntagTour = 0)
    OR TourLT.VsaID IS NULL
  );

GO