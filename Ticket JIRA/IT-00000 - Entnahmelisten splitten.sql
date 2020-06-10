DECLARE @EntnKoID int = 1936579;

DECLARE @NewEntnKo TABLE (
  EntnKoID int
);

INSERT INTO EntnKo (Status, LagerID, VsaID, TraeArtiID, AuftragID, NurUserID, Wochentag, TourenID, Datum, AnzTeile, OrderByID, AnforderLagerID, LiefLagerID, DruckDatum)
OUTPUT inserted.ID
INTO @NewEntnKo(EntnKoID)
SELECT EntnKo.Status, EntnKo.LagerID, EntnKo.VsaID, EntnKo.TraeArtiID, EntnKo.AuftragID, EntnKo.NurUserID, EntnKo.Wochentag, EntnKo.TourenID, EntnKo.Datum, COUNT(Teile.ID) AS AnzTeile, EntnKo.OrderByID, EntnKo.AnforderLagerID, EntnKo.LiefLagerID, EntnKo.DruckDatum
FROM EntnKo
JOIN EntnPo ON EntnPo.EntnKoID = EntnKo.ID
JOIN Teile ON Teile.EntnPoID = EntnPo.ID
WHERE EntnKo.ID = @EntnKoID
  AND Teile.Entnommen = 1
GROUP BY EntnKo.Status, EntnKo.LagerID, EntnKo.VsaID, EntnKo.TraeArtiID, EntnKo.AuftragID, EntnKo.NurUserID, EntnKo.Wochentag, EntnKo.TourenID, EntnKo.Datum, EntnKo.OrderByID, EntnKo.AnforderLagerID, EntnKo.LiefLagerID, EntnKo.DruckDatum;

UPDATE EntnPo SET EntnKoID = (SELECT EntnKoID FROM @NewEntnKo)
FROM EntnPo
JOIN Teile ON Teile.EntnPoID = EntnPo.ID
WHERE EntnPo.EntnKoID = @EntnKoID
  AND Teile.Entnommen = 1;

UPDATE EntnKo SET AnzTeile = x.AnzTeile
FROM EntnKo
JOIN (
  SELECT EntnPo.EntnKoID, COUNT(Teile.ID) AS AnzTeile
  FROM EntnPo
  JOIN Teile ON Teile.EntnPoID = EntnPo.ID
  WHERE EntnPo.EntnKoID = @EntnKoID
  GROUP BY EntnPo.EntnKoID
) AS x ON x.EntnKoID = EntnKo.ID;

SELECT EntnKoID FROM @NewEntnKo;