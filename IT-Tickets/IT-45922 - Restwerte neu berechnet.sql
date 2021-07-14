SELECT RechKo.RechNr, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Teile.Ausdienst, KdArti.BasisRestwert, KdArti.AfaWochen, Teile.AusdRestw AS [Restwert fakturiert], TeileRw.RestwertInfo AS [Restwert korrigiert]
FROM Teile
JOIN RechPo ON Teile.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Week ON Teile.Ausdienst = Week.Woche
JOIN Week AS WeekBefore ON DATEADD(week, -1, Week.VonDat) BETWEEN WeekBefore.VonDat AND WeekBefore.BisDat
JOIN KdArti ON Teile.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
CROSS APPLY funcGetRestwert(Teile.ID, WeekBefore.Woche, 1) AS TeileRW
WHERE RechKo.RechNr IN (30084727, 30091301);