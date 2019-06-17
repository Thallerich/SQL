SELECT Artikel.ArtikelNr AS SetArtikelNr, Artikel.ArtikelBez$LAN$ AS SetArtikelBez, OPSets.Position, OPSets.Menge, Inhalt.ArtikelNr AS InhaltArtikelNr, Inhalt.ArtikelBez$LAN$ AS InhaltArtikelBez, OPSets.MitTape AS [Mit Tape?], RTRIM(CAST(OPSets.PackInfo AS nvarchar(1000))) AS Packinfo, Ersatz1.ArtikelNr AS Ersatz1ArtikelNr, Ersatz1.ArtikelBez$LAN$ AS Ersatz1ArtikelBez, Ersatz2.ArtikelNr AS Ersatz2ArtikelNr, Ersatz2.ArtikelBez$LAN$ AS Ersatz2ArtikelBez, Ersatz3.ArtikelNr AS Ersatz3ArtikelNr, Ersatz3.ArtikelBez$LAN$ AS Ersatz3ArtikelBez, Ersatz4.ArtikelNr AS Ersatz4ArtikelNr, Ersatz4.ArtikelBez$LAN$ AS Ersatz4ArtikelBez
FROM OPSets, Artikel, Artikel AS Inhalt, Artikel AS Ersatz1, Artikel AS Ersatz2, Artikel AS Ersatz3, Artikel AS Ersatz4
WHERE OPSets.ArtikelID = Artikel.ID
  AND OPSets.Artikel1ID = Inhalt.ID
  AND OPSets.Artikel2ID = Ersatz1.ID
  AND OPSets.Artikel3ID = Ersatz2.ID
  AND OPSets.Artikel4ID = Ersatz3.ID
  AND OPSets.Artikel5ID = Ersatz4.ID
  AND Artikel.ID IN (
    SELECT KdArti.ArtikelID
    FROM KdArti
    WHERE KdArti.KundenID = $ID$
      AND KdArti.Status = N'A'
  )
ORDER BY SetArtikelNr, OPSets.Position;