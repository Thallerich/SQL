SELECT Standort.SuchCode AS Produktion, CAST(DATEADD(hour, TourPrio.OPSetVorlaufStd, CAST(AnfKo.LieferDatum AS datetime)) AS date) AS Bereitstellung, IArtikel.ArtikelNr AS [ArtikelNr Inhalt], IArtikel.ArtikelBez$LAN$ AS [Artikelbezeichnung Inhalt], SUM(OPSets.Menge * (AnfPo.Angefordert - AnfPo.Geliefert)) AS [benötigte Menge Inhalt]
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Fahrt ON AnfKo.FahrtID = Fahrt.ID
JOIN Touren ON IIF(AnfKo.FahrtID > 0, Fahrt.TourenID, AnfKo.TourenID) = Touren.ID
JOIN TourPrio ON Touren.TourPrioID = TourPrio.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN OPSets ON OPSets.ArtikelID = Artikel.ID
JOIN Artikel AS IArtikel ON OPSets.Artikel1ID = IArtikel.ID
JOIN Standort ON AnfKo.ProduktionID = Standort.ID
WHERE AnfKo.LieferDatum >= GETDATE()
  AND CAST(DATEADD(hour, TourPrio.OPSetVorlaufStd, CAST(AnfKo.LieferDatum AS datetime)) AS date) = $1$
  AND AnfKo.Status < N'P'
  AND AnfKo.ProduktionID = $2$
  AND AnfPo.Angefordert > 0
  AND Bereich.IstOP = 1
  AND ArtGru.OPBarcode = 1
  AND ArtGru.Steril = 1
GROUP BY Standort.SuchCode, CAST(DATEADD(hour, TourPrio.OPSetVorlaufStd, CAST(AnfKo.LieferDatum AS datetime)) AS date), IArtikel.ArtikelNr, IArtikel.ArtikelBez$LAN$;