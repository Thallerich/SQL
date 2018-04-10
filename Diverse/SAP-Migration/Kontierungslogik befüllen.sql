USE Wozabal;
GO

SELECT *
INTO __RPoKontoBackup
FROM RPoKonto;

DELETE FROM RPoKonto WHERE FirmaID IN (SELECT DISTINCT FirmaID FROM [SRVATENADVTEST\ADVANTEX].Wozabal.dbo.__KTrLogik);
GO

INSERT INTO RPoKonto (BereichID, RPoTypeID, BrancheID, FirmaID, KdGfID, Art, ArtGruID, MWStID, Bez, KontenID, RKoTypeID, SteuerSchl, AbwKostenstelle)
SELECT BereichID, RPoTypeID, BrancheID, FirmaID, KdGfID, Art, ArtGruID, MWStID, Bez, KontenID, RKoTypeID, SteuerSchl, AbwKostenstelle
FROM [SRVATENADVTEST\ADVANTEX].Wozabal.dbo.__KTrLogik;

GO