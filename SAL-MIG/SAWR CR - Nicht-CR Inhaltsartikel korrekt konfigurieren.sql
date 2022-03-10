UPDATE KdArti SET LiefArtID = CASE SetArtGru.Gruppe WHEN N'CRSU' THEN 4 WHEN N'CRST' THEN 66 ELSE KdArti.LiefArtID END, MaxWaschen = IIF(KdArti.MaxWaschen = 0, 50, KdArti.MaxWaschen), WaschPrgID = (SELECT ID FROM WaschPrg WHERE WaschPrg = N'PES'), UsesBkOpTeile = 1
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN WaschPrg ON KdArti.WaschPrgID = WaschPrg.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN OPSets ON OPSets.Artikel1ID = KdArti.ArtikelID
JOIN Artikel SetArti ON OPSets.ArtikelID = SetArti.ID
JOIN Bereich SetBereich ON SetArti.BereichID = SetBereich.ID
JOIN ArtGru SetArtGru ON SetArti.ArtGruID = SetArtGru.ID
WHERE SetBereich.Bereich = N'CR'
  AND Bereich.Bereich != N'CR'
  AND Artikel.ID > 0
  AND EXISTS (
    SELECT ka.*
    FROM KdArti ka
    WHERE ka.KundenID = Kunden.ID
      AND ka.ArtikelID = OPSets.ArtikelID
  )
  AND EXISTS (
      SELECT Vsa.*
      FROM Vsa
      JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID
      WHERE StandBer.BereichID = SetBereich.ID
        AND Vsa.KundenID = KdArti.KundenID
        AND StandBer.ProduktionID = (SELECT ID FROM Standort WHERE SuchCode = N'SAWR')
    );