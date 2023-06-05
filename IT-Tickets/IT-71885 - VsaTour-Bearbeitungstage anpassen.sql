IF OBJECT_ID(N'_IT71885') IS NULL
  CREATE TABLE _IT71885 (
    VsaTourID int,
    MinBearbTage int
  );

UPDATE VsaTour SET MinBearbTage = 2
OUTPUT deleted.ID, deleted.MinBearbTage
INTO _IT71885 (VsaTourID, MinBearbTage)
WHERE ID IN (
  SELECT VsaTour.ID
  FROM VsaTour
  JOIN Vsa ON VsaTour.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  WHERE Bereich.Bereich != N'ST'
    AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
    AND VsaTour.MinBearbTage != 2
    AND Kunden.KdNr IN (202764, 240068)
    AND Touren.Wochentag = 1
);