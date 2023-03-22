IF OBJECT_ID('_IT69351_Vsa_20230323') IS NULL
  CREATE TABLE _IT69351_Vsa_20230323 (
    VsaID int PRIMARY KEY,
    StandKonID int,
    ServTypeID int,
    Name3 nvarchar(40) COLLATE Latin1_General_CS_AS,
    Zeitpunkt datetime DEFAULT GETDATE()
  );

GO

IF OBJECT_ID('_IT68934_VsaTour_20230323') IS NULL
  CREATE TABLE _IT68934_VsaTour_20230323 (
    VsaTourID int PRIMARY KEY,
    MinBearbTage int,
    Zeitpunkt datetime DEFAULT GETDATE()
  );

GO

WITH BaseData AS (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez, StandKon.ID AS StandKonID, StandKon.StandKonBez, ServType.ID AS ServTypeID, ServType.ServTypeBez, LEFT(_IT69351_StandKon_20230323.VsaName3 + ISNULL(N' - ' + Vsa.Name3, N''), 40) AS Name3
  FROM Salesianer.dbo._IT69351_StandKon_20230323
  JOIN Kunden ON _IT69351_StandKon_20230323.KdNr = Kunden.KdNr
  JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = _IT69351_StandKon_20230323.VsaNr
  JOIN StandKon ON StandKon.StandKonBez = _IT69351_StandKon_20230323.StandKon
  JOIN ServType ON ServType.ServTypeBez = _IT69351_StandKon_20230323.ServType
)
UPDATE Vsa SET StandKonID = BaseData.StandKonID, ServTypeID = BaseData.ServTypeID, Vsa.Name3 = BaseData.Name3
OUTPUT deleted.ID, deleted.StandKonID, deleted.ServTypeID, deleted.Name3
INTO _IT69351_Vsa_20230323 (VsaID, StandKonID, ServTypeID, Name3)
FROM BaseData
WHERE BaseData.VsaID = Vsa.ID;

GO

WITH BaseData AS (
  SELECT VsaTour.ID AS VsaTourID, _IT69351_TourTage_20230323.Bearbeitungstage
  FROM Salesianer.dbo._IT69351_TourTage_20230323
  JOIN Touren ON _IT69351_TourTage_20230323.Tour = Touren.Tour
  JOIN Kunden ON _IT69351_TourTage_20230323.KdNr = Kunden.KdNr
  JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = _IT69351_TourTage_20230323.VsaNr
  JOIN VsaTour ON VsaTour.TourenID = Touren.ID AND VsaTour.VsaID = Vsa.ID AND VsaTour.BisDatum > CAST(GETDATE() AS date)
  JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID AND _IT69351_TourTage_20230323.Bereich = Bereich.BereichBez
)
UPDATE VsaTour SET MinBearbTage = BaseData.Bearbeitungstage
OUTPUT deleted.ID, deleted.MinBearbTage
INTO _IT68934_VsaTour_20230323 (VsaTourID, MinBearbTage)
FROM BaseData
WHERE BaseData.VsaTourID = VsaTour.ID
  AND VsaTour.MinBearbTage != BaseData.Bearbeitungstage;

GO

UPDATE AnfKo SET ProduktionID = x.ProduktionID
FROM (
  SELECT Vsa.ID AS VsaID, StandBer.ProduktionID
  FROM Vsa
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID
  WHERE StandBer.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'FW')
    AND Vsa.ID IN (SELECT _IT69351_Vsa_20230323.VsaID FROM _IT69351_Vsa_20230323)
) AS x
WHERE x.VsaID = AnfKo.VsaID
  AND AnfKo.LieferDatum > GETDATE()
  AND AnfKo.Status <= N'I'
  AND AnfKo.ProduktionID != x.ProduktionID;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Fehlende Artikel zu bestehenden Packzetteln hinzufügen                                                                    ++ */
/* ++ Separater Schritt - erst nach GO von Larissa!                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/*
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @NewAnfPo TABLE (
  AnfKoID int,
  AbteilID int,
  KdArtiID int,
  ArtGroeID int,
  AnlageUserID_ int,
  UserID_ int
);

INSERT INTO @NewAnfPo (AnfKoID, AbteilID, KdArtiID, ArtGroeID, AnlageUserID_, UserID_)
SELECT AnfKo.ID AS AnfKoID, VsaAnf.AbteilID, VsaAnf.KdArtiID, IIF(Bereich.VsaAnfGroe = 1, VsaAnf.ArtGroeID, -1) AS ArtGroeID, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM AnfKo
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN VsaAnf ON VsaAnf.VsaID = Vsa.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID
WHERE StandBer.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'FW')
  AND Vsa.ID IN (SELECT _IT69351_Vsa_20230323.VsaID FROM _IT69351_Vsa_20230323)
  AND AnfKo.LieferDatum > GETDATE()
  AND AnfKo.Status < N'I'
  AND VsaAnf.[Status] IN (N'A', N'C')
  AND NOT EXISTS (
    SELECT AnfPo.*
    FROM AnfPo
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND AnfPo.KdArtiID = VsaAnf.KdArtiID
  );

INSERT INTO AnfPo (AnfKoID, AbteilID, KdArtiID, ArtGroeID, AnlageUserID_, UserID_)
SELECT AnfKoID, AbteilID, KdArtiID, ArtGroeID, AnlageUserID_, UserID_
FROM @NewAnfPo;
*/


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ "Zu viel" Artikel von bestehenden Packzetteln entfernen                                                                   ++ */
/* ++ Separater Schritt - erst nach GO von Larissa!                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* 
DROP TABLE IF EXISTS #AnfPoNurEB;
GO

SELECT AnfPo.ID
INTO #AnfPoNurEB
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID
JOIN VsaAnf ON VsaAnf.VsaID = Vsa.ID AND VsaAnf.KdArtiID = AnfPo.KdArtiID AND AnfPo.ArtGroeID = IIF(Bereich.VsaAnfGroe = 1, VsaAnf.ArtGroeID, -1)
WHERE StandBer.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'FW')
  AND Vsa.ID IN (SELECT _IT69351_Vsa_20230323.VsaID FROM _IT69351_Vsa_20230323)
  AND AnfKo.LieferDatum > GETDATE()
  AND AnfKo.Status < N'I'
  AND VsaAnf.[Status] IN (N'E')
  AND AnfPo.Angefordert != 0;

GO

UPDATE AnfPo SET Angefordert = 0
WHERE ID IN (
  SELECT ID
  FROM #AnfPoNurEB
);

GO
*/