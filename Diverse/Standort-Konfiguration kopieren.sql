DECLARE @Source nvarchar(40) = N'BK: Lenzing2 - Lager Lenzing->Linz';
DECLARE @Destination nvarchar(40) = N'BK: Lenzing2 - Lager Enns->Linz';
DECLARE @DestinationWarhouse nvarchar(15) = N'WOLI';
DECLARE @DestinationLocalWarehouse nvarchar(15) = N'WOEN';

UPDATE Destination SET ProduktionID = Source.ProduktionID,
  ExpeditionID = Source.ExpeditionID,
  LagerID = (SELECT ID FROM Standort WHERE SuchCode = @DestinationWarhouse AND Standort.Lager = 1),
  LokalLagerID = (SELECT ID FROM Standort WHERE SuchCode = @DestinationLocalWarehouse AND Standort.Lager = 1),
  KundendienstID = Source.KundendienstID,
  OPLagerID = Source.OPLagerID,
  PZArtID = Source.PZArtID,
  UmsatzStandortID = Source.UmsatzStandortID,
  ZielNrKDLagerID = Source.ZielNrKDLagerID,
  ZielNrVerwendLagerID = Source.ZielNrVerwendLagerID,
  ZielNrUnreinID = Source.ZielNrUnreinID,
  KdAnfLagerArtID = Source.KdAnfLagerArtID,
  SchmAnfLagerArtID = Source.SchmAnfLagerArtID,
  EinrichtLagerArtID = Source.EinrichtLagerArtID,
  ExpAnfLagerArtID = Source.ExpAnfLagerArtID,
  AnfLagerVSAID = Source.AnfLagerVSAID,
  SpezialArtikelLagerID = Source.SpezialArtikelLagerID
FROM StandBer AS Destination
JOIN StandBer AS Source ON Destination.BereichID = Source.BereichID
WHERE Destination.StandKonID = (SELECT ID FROM StandKon WHERE StandKonBez = @Destination)
  AND Source.StandKonID = (SELECT ID FROM StandKon WHERE StandKonBez = @Source);