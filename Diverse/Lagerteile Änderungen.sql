USE Wozabal
GO

SELECT TeileLMA.MassOrtID, TeileLMA.PlatzID, TeileLMA.Mass, TeileLag.Barcode, TeileLag.Status, Status.StatusBez AS StatusBez
FROM TeileLMA
JOIN TeileLag ON TeileLMA.TeileLagID = TeileLag.ID
JOIN Status ON TeileLag.Status = Status.Status AND Status.Tabelle = N'TEILELAG'
JOIN (
  SELECT TeilMass.MassOrtID, TeilMass.PlatzID, TeilMass.Mass, Teile.ArtGroeID
  FROM TeilMass
  JOIN Teile ON TeilMass.TeileID = Teile.ID
  WHERE Teile.Barcode = N'8836871979'
) TeilData ON TeilData.MassOrtID = TeileLMA.MassOrtID AND TeilData.PlatzID = TeileLMA.PlatzID AND TeilData.ArtGroeID = TeileLag.ArtGroeID AND TeilData.Mass = TeileLMA.Mass
WHERE TeileLag.Status < N'X'

GO