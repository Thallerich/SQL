DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @Vsa TABLE (
  KundenID int,
  VsaID int
);

INSERT INTO @Vsa (KundenID, VsaID)
SELECT DISTINCT Kunden.ID, Vsa.ID
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN VsaTour ON VsaTour.VsaID = Vsa.ID
JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN Standort AS Expedition ON Touren.ExpeditionID = Expedition.ID
WHERE Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND (Expedition.SuchCode LIKE N'UKL_' OR Expedition.SuchCode = N'GRAZ')
  AND KdGf.KurzBez = N'GAST'
  AND Bereich.Bereich = N'FW'
  AND Vsa.ID != 6112460;

INSERT INTO VsaTexte (KundenID, VsaID, TextArtID, Memo, VonDatum, BisDatum, Anlage_, Update_, AnlageUserID_, UserID_)
SELECT v.KundenID, v.VsaID, VsaTexte.TextArtID, VsaTexte.Memo, VsaTexte.VonDatum, VsaTexte.BisDatum, GETDATE(), GETDATE(), @UserID, @UserID
FROM VsaTexte
CROSS JOIN @Vsa v
WHERE VsaTexte.ID = 178138;