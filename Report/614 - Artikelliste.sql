DROP TABLE IF EXISTS #TmpArtiList;

SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelNr2 AS [BMD-Nr.], Artikel.SuchCode AS [Artikel-Stichwort], Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Bereich, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe, Artikel.PackMenge, Me.MeBez$LAN$ AS Mengeneinheit, Status.StatusBez AS Artikelstatus, Artikel.Anlage_ AS Artikelanlage, ISNULL(Mitarbei.UserName, N'(unbekannt)') AS Anlagebenutzer, 0 AS [Liefermenge letzte 6 Monate]
INTO #TmpArtiList
FROM Bereich, ArtGru, Me, (SELECT Status.Status, Status.StatusBez$LAN$ AS StatusBez FROM Status WHERE Status.Tabelle = 'ARTIKEL') AS Status, Artikel
LEFT OUTER JOIN Mitarbei ON Artikel.AnlageUserID_ = Mitarbei.ID
WHERE Artikel.BereichID = Bereich.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND Artikel.Status = Status.Status
  AND Artikel.MeID = Me.ID
  AND Bereich.ID IN ($1$)
  AND ArtGru.ID IN ($2$)
ORDER BY Bereich, Artikelgruppe, Artikel.ArtikelNr;

UPDATE ArtiList SET ArtiList.[Liefermenge letzte 6 Monate] = x.Liefermenge
FROM #TmpArtiList AS ArtiList, (
  SELECT KdArti.ArtikelID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo, LsKo, KdArti
  WHERE LsPo.LsKoID = LsKo.ID
    AND LsPo.KdArtiID = KdArti.ID
    AND LsKo.Datum >= CONVERT(date, DATEADD(month, -6, GETDATE()))
  GROUP BY KdArti.ArtikelID
) AS x
WHERE x.ArtikelID = ArtiList.ArtikelID;

SELECT * FROM #TmpArtiList;