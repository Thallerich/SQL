IF OBJECT_ID('_IT67442_Vsa') IS NULL
  CREATE TABLE _IT67442_Vsa (
    VsaID int PRIMARY KEY,
    StandKonID int,
    ServTypeID int,
    Name3 nvarchar(40) COLLATE Latin1_General_CS_AS,
    Zeitpunkt datetime DEFAULT GETDATE()
  );

GO

IF OBJECT_ID('_IT67442_VsaTour') IS NULL
  CREATE TABLE _IT67442_VsaTour (
    VsaTourID int PRIMARY KEY,
    MinBearbTage int,
    Zeitpunkt datetime DEFAULT GETDATE()
  );

GO

WITH BaseData AS (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez, StandKon.ID AS StandKonID, StandKon.StandKonBez, ServType.ID AS ServTypeID, ServType.ServTypeBez, LEFT(_IT67442_StandKon.VsaName3 COLLATE Latin1_General_CS_AS + ISNULL(N' - ' + Vsa.Name3, N''), 40) AS Name3
  FROM Salesianer.dbo._IT67442_StandKon
  JOIN Kunden ON _IT67442_StandKon.KdNr = Kunden.KdNr
  JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = _IT67442_StandKon.VsaNr
  JOIN StandKon ON StandKon.StandKonBez = _IT67442_StandKon.StandKon COLLATE Latin1_General_CS_AS
  JOIN ServType ON ServType.ServTypeBez = _IT67442_StandKon.ServType COLLATE Latin1_General_CS_AS
)
UPDATE Vsa SET StandKonID = BaseData.StandKonID, ServTypeID = BaseData.ServTypeID, Vsa.Name3 = BaseData.Name3
OUTPUT deleted.ID, deleted.StandKonID, deleted.ServTypeID, deleted.Name3
INTO _IT67442_Vsa (VsaID, StandKonID, ServTypeID, Name3)
FROM BaseData
WHERE BaseData.VsaID = Vsa.ID;

GO

WITH BaseData AS (
  SELECT VsaTour.ID AS VsaTourID, _IT67442_TourTage.Bearbeitungstage
  FROM Salesianer.dbo._IT67442_TourTage
  JOIN Touren ON _IT67442_TourTage.Tour COLLATE Latin1_General_CS_AS = Touren.Tour
  JOIN Kunden ON _IT67442_TourTage.KdNr = Kunden.KdNr
  JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = _IT67442_TourTage.VsaNr
  JOIN VsaTour ON VsaTour.TourenID = Touren.ID AND VsaTour.VsaID = Vsa.ID AND VsaTour.BisDatum > CAST(GETDATE() AS date)
  JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID AND _IT67442_TourTage.Bereich COLLATE Latin1_General_CS_AS = Bereich.BereichBez
)
UPDATE VsaTour SET MinBearbTage = BaseData.Bearbeitungstage
OUTPUT deleted.ID, deleted.MinBearbTage
INTO _IT67442_VsaTour (VsaTourID, MinBearbTage)
FROM BaseData
WHERE BaseData.VsaTourID = VsaTour.ID;

GO

UPDATE AnfKo SET ProduktionID = x.ProduktionID
FROM (
  SELECT Vsa.ID AS VsaID, StandBer.ProduktionID
  FROM Vsa
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID
  WHERE StandBer.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'FW')
    AND Vsa.ID IN (SELECT _IT67442_Vsa.VsaID FROM _IT67442_Vsa)
) AS x
WHERE x.VsaID = AnfKo.VsaID
  AND AnfKo.LieferDatum > GETDATE()
  AND AnfKo.Status <= N'I';

GO