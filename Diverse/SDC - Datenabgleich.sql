SELECT Touren.*
FROM Touren
JOIN [SRVATLESDC01.WOZABAL.INT\ADVANTEX].Wozabal_Lenzing_2.dbo.Touren AS SDCTouren ON Touren.ID = SDCTouren.ID
WHERE Touren.Tour <> SDCTouren.Tour;

SELECT Vsa.*
FROM Vsa
JOIN [SRVATLESDC01.WOZABAL.INT\ADVANTEX].Wozabal_Lenzing_2.dbo.Vsa AS SDCVsa ON Vsa.ID = SDCVsa.ID
WHERE Vsa.VsaNr <> SDCVsa.VsaNr OR Vsa.KundenID <> SDCVsa.KundenID;

SELECT VsaTour.*
FROM VsaTour
JOIN [SRVATLESDC01.WOZABAL.INT\ADVANTEX].Wozabal_Lenzing_2.dbo.VsaTour AS SDCVsaTour ON VsaTour.ID = SDCVsaTour.ID
WHERE VsaTour.VsaID <> SDCVsaTour.VsaID OR VsaTour.KdBerID <> SDCVsaTour.KdBerID OR VsaTour.TourenID <> SDCVsaTour.TourenID OR VsaTour.VonDatum <> SDCVsaTour.VonDatum;

SELECT Traeger.*
FROM Traeger
JOIN [SRVATLESDC01.WOZABAL.INT\ADVANTEX].Wozabal_Lenzing_2.dbo.Traeger AS SDCTraeger ON Traeger.ID = SDCTraeger.ID
WHERE Traeger.VsaID <> SDCTraeger.VsaID OR Traeger.Traeger <> SDCTraeger.Traeger;

SELECT TraeArti.*
FROM TraeArti
JOIN [SRVATLESDC01.WOZABAL.INT\ADVANTEX].Wozabal_Lenzing_2.dbo.TraeArti AS SDCTraeArti ON TraeArti.ID = SDCTraeArti.ID
WHERE TraeArti.TraegerID <> SDCTraeArti.TraegerID OR TraeArti.KdArtiID <> SDCTraeArti.KdArtiID OR TraeArti.ArtGroeID <> SDCTraeArti.ArtGroeID;

SELECT Teile.ID AS TeileID, Teile.Status AS WozStatus, SDCTeile.Status AS SDCStatus
-- UPDATE Teile SET [Status] = Teile.[Status]
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN KdArti ON Teile.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON KdBer.BereichID = StandBer.BereichID AND Vsa.StandKonID = StandBer.StandKonID
JOIN [SRVATLESDC01.WOZABAL.INT\ADVANTEX].Wozabal_Lenzing_2.dbo.Teile AS SDCTeile ON Teile.ID = SDCTeile.ID
WHERE Teile.Status <> SDCTeile.Status
  AND StandBer.SdcDevID = 2;

SELECT Hinweis.*
FROM Hinweis
JOIN [SRVATLESDC01.WOZABAL.INT\ADVANTEX].Wozabal_Lenzing_2.dbo.Hinweis AS SDCHinweis ON Hinweis.ID = SDCHinweis.ID
WHERE Hinweis.Aktiv <> SDCHinweis.Aktiv;

SELECT JahrLief.*
-- UPDATE JahrLief SET Lieferwochen = JahrLief.Lieferwochen
FROM JahrLief
JOIN [SRVATLESDC01.WOZABAL.INT\ADVANTEX].Wozabal_Lenzing_2.dbo.JahrLief AS SDCJahrLief ON JahrLief.ID = SDCJahrLief.ID
WHERE JahrLief.Lieferwochen <> SDCJahrLief.LieferWochen OR JahrLief.TableName <> SDCJahrLief.TableName OR JahrLief.TableID <> SDCJahrLief.TableID;