/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import-File: "C:\Users\thalst.SAL\OneDrive - Salesianer Miettex GmbH\Attachments\SAWR_CR_SetArtikel.csv"                  ++ */
/* ++   KdNr int                                                                                                                ++ */
/* ++   RRSetArtikelNr nchar(15)                                                                                                ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* 
ALTER TABLE __CRSetArtikel DROP CONSTRAINT PK___CRSetArtikel;
GO
ALTER TABLE __CRSetArtikel ALTER COLUMN RRSetArtikelNr nchar(15) COLLATE Latin1_General_CS_AS NOT NULL;
GO
ALTER TABLE __CRSetArtikel ADD CONSTRAINT PK___CRSetArtikel PRIMARY KEY (KdNr, RRSetArtikelNr);
GO
 */

DECLARE @InsertedKdArti TABLE (
  KundenID int,
  ArtikelID int
);

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO KdArti (KundenID, ArtikelID, KdBerID, LiefArtID, WaschPrgID, UserID_, AnlageUserID_)
OUTPUT inserted.KundenID, inserted.ArtikelID
INTO @InsertedKdArti
SELECT Kunden.ID AS KundenID, Artikel.ID AS ArtikelID, KdBer.ID AS KdBerID, Artikel.LiefArtID, Artikel.WaschPrgID, @UserID AS UserID_, @UserID AS AnlageUserID_
FROM __CRSetArtikel
JOIN Kunden ON __CRSetArtikel.KdNr = Kunden.KdNr
JOIN Artikel ON __CRSetArtikel.RRSetArtikelNr = Artikel.ArtikelNr
JOIN KdBer ON KdBer.KundenID = Kunden.ID AND KdBer.BereichID = Artikel.BereichID;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez
FROM @InsertedKdArti AS IKA
JOIN Kunden ON IKA.KundenID = Kunden.ID
JOIN Artikel ON IKA.ArtikelID = Artikel.ID;

GO