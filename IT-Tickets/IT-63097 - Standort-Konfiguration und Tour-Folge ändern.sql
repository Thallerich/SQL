/* CREATE TABLE __IT63097_Vsa (
  VsaID int PRIMARY KEY,
  StandKonID int,
  ServTypeID int,
  Name3 nvarchar(40) COLLATE Latin1_General_CS_AS,
  Zeitpunkt datetime DEFAULT GETDATE()
);

GO

CREATE TABLE __IT63097_VsaTour (
  VsaTourID int PRIMARY KEY,
  MinBearbTage int,
  Zeitpunkt datetime DEFAULT GETDATE()
);

GO */

/* WITH BaseData AS (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez, StandKon.ID AS StandKonID, StandKon.StandKonBez, ServType.ID AS ServTypeID, ServType.ServTypeBez, LEFT(__IT63097StandKon_1.VsaName3 COLLATE Latin1_General_CS_AS + ISNULL(N' - ' + Vsa.Name3, N''), 40) AS Name3
  FROM Salesianer.dbo.__IT63097StandKon_1
  JOIN Kunden ON __IT63097StandKon_1.KdNr = Kunden.KdNr
  JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = __IT63097StandKon_1.VsaNr
  JOIN StandKon ON StandKon.StandKonBez = __IT63097StandKon_1.StandKon COLLATE Latin1_General_CS_AS
  JOIN ServType ON ServType.ServTypeBez = __IT63097StandKon_1.ServType COLLATE Latin1_General_CS_AS
)
UPDATE Vsa SET StandKonID = BaseData.StandKonID, ServTypeID = BaseData.ServTypeID, Vsa.Name3 = BaseData.Name3
OUTPUT deleted.ID, deleted.StandKonID, deleted.ServTypeID, deleted.Name3
INTO __IT63097_Vsa (VsaID, StandKonID, ServTypeID, Name3)
FROM BaseData
WHERE BaseData.VsaID = Vsa.ID;

GO

WITH BaseData AS (
  SELECT VsaTour.ID AS VsaTourID, __IT63097TourTage_1.Bearbeitungstage
  FROM Salesianer.dbo.__IT63097TourTage_1
  JOIN Touren ON __IT63097TourTage_1.Tour COLLATE Latin1_General_CS_AS = Touren.Tour
  JOIN Kunden ON __IT63097TourTage_1.KdNr = Kunden.KdNr
  JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = __IT63097TourTage_1.VsaNr
  JOIN VsaTour ON VsaTour.TourenID = Touren.ID AND VsaTour.VsaID = Vsa.ID AND VsaTour.Folge = __IT63097TourTage_1.Folge AND VsaTour.BisDatum > CAST(GETDATE() AS date)
  JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID AND __IT63097TourTage_1.Bereich COLLATE Latin1_General_CS_AS = Bereich.BereichBez
)
UPDATE VsaTour SET MinBearbTage = BaseData.Bearbeitungstage
OUTPUT deleted.ID, deleted.MinBearbTage
INTO __IT63097_VsaTour (VsaTourID, MinBearbTage)
FROM BaseData
WHERE BaseData.VsaTourID = VsaTour.ID;

GO */

WITH BaseData AS (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez, StandKon.ID AS StandKonID, StandKon.StandKonBez, ServType.ID AS ServTypeID, ServType.ServTypeBez, LEFT(__IT63097StandKon_2.VsaName3 COLLATE Latin1_General_CS_AS + ISNULL(N' - ' + Vsa.Name3, N''), 40) AS Name3
  FROM Salesianer.dbo.__IT63097StandKon_2
  JOIN Kunden ON __IT63097StandKon_2.KdNr = Kunden.KdNr
  JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = __IT63097StandKon_2.VsaNr
  JOIN StandKon ON StandKon.StandKonBez = __IT63097StandKon_2.StandKon COLLATE Latin1_General_CS_AS
  JOIN ServType ON ServType.ServTypeBez = __IT63097StandKon_2.ServType COLLATE Latin1_General_CS_AS
)
UPDATE Vsa SET StandKonID = BaseData.StandKonID, ServTypeID = BaseData.ServTypeID, Vsa.Name3 = BaseData.Name3
OUTPUT deleted.ID, deleted.StandKonID, deleted.ServTypeID, deleted.Name3
INTO __IT63097_Vsa (VsaID, StandKonID, ServTypeID, Name3)
FROM BaseData
WHERE BaseData.VsaID = Vsa.ID;

GO

WITH BaseData AS (
  SELECT VsaTour.ID AS VsaTourID, __IT63097TourTage_2.Bearbeitungstage
  FROM Salesianer.dbo.__IT63097TourTage_2
  JOIN Touren ON __IT63097TourTage_2.Tour COLLATE Latin1_General_CS_AS = Touren.Tour
  JOIN Kunden ON __IT63097TourTage_2.KdNr = Kunden.KdNr
  JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = __IT63097TourTage_2.VsaNr
  JOIN VsaTour ON VsaTour.TourenID = Touren.ID AND VsaTour.VsaID = Vsa.ID AND VsaTour.Folge = __IT63097TourTage_2.Folge AND VsaTour.BisDatum > CAST(GETDATE() AS date)
  JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID AND __IT63097TourTage_2.Bereich COLLATE Latin1_General_CS_AS = Bereich.BereichBez
)
UPDATE VsaTour SET MinBearbTage = BaseData.Bearbeitungstage
OUTPUT deleted.ID, deleted.MinBearbTage
INTO __IT63097_VsaTour (VsaTourID, MinBearbTage)
FROM BaseData
WHERE BaseData.VsaTourID = VsaTour.ID;

GO