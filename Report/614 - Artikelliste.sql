SELECT Artikel.ID AS ArtikelID,
  Artikel.ArtikelNr,
  Artikel.ArtikelNr2 AS [BMD-Nr.],
  Artikel.SuchCode AS [Artikel-Stichwort],
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ABC.ABC AS [ABC-Klasse],
  ABC.ABCBez AS [ABC-Klasse Bezeichnung],
  Bereich.BereichBez$LAN$ AS Bereich,
  ArtGru.ArtGruBez$LAN$ AS Artikelgruppe,
  Artikel.PackMenge,
  Me.MeBez$LAN$ AS Mengeneinheit,
  Artikelstatus.StatusBez AS Artikelstatus,
  Artikel.Anlage_ AS Artikelanlage,
  ISNULL(Mitarbei.UserName, N'(unbekannt)') AS Anlagebenutzer,
  [Liefermenge letzte 6 Monate] = (
    SELECT SUM(LsPo.Menge)
    FROM LsPo
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID
    JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
    WHERE LsKo.Datum >= CAST(DATEADD(month, -6, GETDATE()) AS date)
      AND KdArti.ArtikelID = Artikel.ID
  )
FROM Artikel
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Me ON Artikel.MeID = Me.ID
JOIN Abc ON Artikel.AbcID = Abc.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'ARTIKEL'
) AS Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
LEFT JOIN Mitarbei ON Artikel.AnlageUserID_ = Mitarbei.ID
WHERE Artikel.BereichID IN ($1$)
  AND Artikel.ArtGruID IN ($2$)
ORDER BY Bereich, Artikelgruppe, Artikel.ArtikelNr;