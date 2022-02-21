DECLARE @ArtiMapEW TABLE (
  ArtikelIDAlt int,
  ArtikelNrAlt nchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelIDNeu int,
  ArtikelNrNeu nchar(15) COLLATE Latin1_General_CS_AS
);

INSERT INTO @ArtiMapEW (ArtikelNrAlt, ArtikelNrNeu)
VALUES (N'191406610000', N'192406610000'), (N'191400120000', N'192400120000'), (N'191406260000', N'192406260000'), (N'191403020000', N'192403020000'), (N'191406380000', N'192406380000'), (N'191406520000', N'192406520000'), (N'191406510100', N'192406510100'), (N'191403060000', N'192403060000'), (N'191403070000', N'192403070000'), (N'191403130000', N'192403130000'), (N'191406930000', N'192406930000'), (N'191403260000', N'192403260000'), (N'191403280000', N'192403280000'), (N'191403270000', N'192403270000'), (N'191409320000', N'192409320001'), (N'492403440000', N'192403440000'), (N'191406820000', N'192403091000'), (N'114470025150', N'114470025050'), (N'114470025170', N'114470025070');

UPDATE ArtiMapEW SET ArtikelIDAlt = Artikel.ID
FROM @ArtiMapEW ArtiMapEW
JOIN Artikel ON ArtiMapEW.ArtikelNrAlt = Artikel.ArtikelNr;

UPDATE ArtiMapEW SET ArtikelIDNeu = Artikel.ID
FROM @ArtiMapEW ArtiMapEW
JOIN Artikel ON ArtiMapEW.ArtikelNrNeu = Artikel.ArtikelNr;

IF OBJECT_ID(N'_EWTeileForCIT') IS NULL
  CREATE TABLE _EWTeileForCIT (
    OPTeileID int
  );

PRINT(N'Updating OP-Teile');

WITH Teileudpate AS (
  SELECT OPTeile.ID AS OPTeileID, ArtiMapEW.ArtikelIDNeu, ArtGroeNeu.ID AS ArtGroeIDNeu
  FROM OPTeile
  JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
  JOIN @ArtiMapEW AS ArtiMapEW ON ArtiMapEW.ArtikelIDAlt = OPTeile.ArtikelID
  JOIN ArtGroe AS ArtGroeNeu ON ArtGroeNeu.ArtikelID = ArtiMapEW.ArtikelIDNeu AND ArtGroeNeu.Groesse = ArtGroe.Groesse
)
UPDATE OPTeile SET ArtikelID = Teileudpate.ArtikelIDNeu, ArtGroeID = Teileudpate.ArtGroeIDNeu
OUTPUT inserted.ID
INTO _EWTeileForCIT (OPTeileID)
FROM Teileudpate
WHERE Teileudpate.OPTeileID = OPTeile.ID;

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

PRINT(N'Merging KdArti');

MERGE INTO KdArti USING (
  SELECT KdArti.ID AS KdArtiID, KdArti.Status, KdArti.KundenID, KdArti.ArtikelID, KdArti.Variante, KdArti.VariantBez, KdArti.WaschPreis, KdArti.LeasPreis, KdArti.Sonderpreis, KdArti.KdBerID, KdArti.Lagerverkauf, KdArti.VkPreis, KdArti.LiefArtID, KdArti.WaschprgID, KdArti.AfaWochen, KdArti.MaxWaschen, KdArti.Basisrestwert, KdArti.EigentumID, KdArti.IstBestandAnpass, KdArti.Vertragsartikel, KdArti.ArtiZwingendBarcodiert, KdArti.ArtiOptionalBarcodiert, KdArti.LeasPreisAbwAbWo, ArtiMapEW.ArtikelIDNeu, KdArti.Referenz, KdArti.WebArtikel
  FROM KdArti
  JOIN @ArtiMapEW AS ArtiMapEW ON ArtiMapEw.ArtikelIDAlt = KdArti.ArtikelID
) AS KdArtiMap (KdArtiID, [Status], KundenID, ArtikelID, Variante, VariantBez, Waschpreis, Leaspreis, Sonderpreis, KdBerID, Lagerverkauf, VkPreis, LiefArtID, WaschPrgID, AfaWochen, MaxWaschen, Basisrestwert, EigentumID, IstBestandAnpass, Vertragsartikel, ArtiZwingendBarcodiert, ArtiOptionalBarcodiert, LeasPreisAbwAbWo, ArtikelIDNeu, Referenz, WebArtikel)
ON KdArti.KundenID = KdArtiMap.KundenID AND KdArti.ArtikelID = KdArtiMap.ArtikelIDNeu AND KdArti.Variante = KdArtiMap.Variante
WHEN NOT MATCHED THEN
  INSERT ([Status], KundenID, ArtikelID, Variante, VariantBez, Waschpreis, Leaspreis, Sonderpreis, KdBerID, Lagerverkauf, VkPreis, LiefArtID, WaschPrgID, AfaWochen, MaxWaschen, Basisrestwert, EigentumID, IstBestandAnpass, Vertragsartikel, ArtiZwingendBarcodiert, ArtiOptionalBarcodiert, LeasPreisAbwAbWo, Referenz, WebArtikel, AnlageUserID_, UserID_)
  VALUES (KdArtiMap.[Status], KdArtiMap.KundenID, KdArtiMap.ArtikelIDNeu, KdArtiMap.Variante, KdArtiMap.VariantBez, KdArtiMap.Waschpreis, KdArtiMap.Leaspreis, KdArtiMap.Sonderpreis, KdArtiMap.KdBerID, KdArtiMap.Lagerverkauf, KdArtiMap.VkPreis, KdArtiMap.LiefArtID, KdArtiMap.WaschPrgID, KdArtiMap.AfaWochen, KdArtiMap.MaxWaschen, KdArtiMap.Basisrestwert, KdArtiMap.EigentumID, KdArtiMap.IstBestandAnpass, KdArtiMap.Vertragsartikel, KdArtiMap.ArtiZwingendBarcodiert, KdArtiMap.ArtiOptionalBarcodiert, KdArtiMap.LeasPreisAbwAbWo, KdArtiMap.Referenz, KdArtiMap.WebArtikel, @UserID, @UserID);

PRINT(N'Old KdArti inactive');

UPDATE KdArti SET [Status] = N'I'
WHERE KdArti.ArtikelID IN (
    SELECT ArtiMapEW.ArtikelIDAlt
    FROM @ArtiMapEW AS ArtiMapEW
  )
  AND KdArti.Status != N'I';

PRINT(N'Merging VsaAnf');

MERGE INTO VsaAnf USING (
  SELECT VsaAnf.[Status], VsaAnf.VsaID, VsaAnf.AbteilID, VsaAnf.KdArtiID, VsaAnf.Liefern1, VsaAnf.Liefern2, VsaAnf.Liefern3, VsaAnf.Liefern4, VsaAnf.Liefern5, VsaAnf.Liefern6, VsaAnf.Liefern7, VsaAnf.SollPuffer, VsaAnf.NormMenge, VsaAnf.Art, VsaAnf.Ungueltig, VsaAnf.UngueltigBis, VsaAnf.LeasingStop, VsaAnf.MitInventur, VsaAnf.Bestand, VsaAnf.BestandKostenlos, VsaAnf.AusstehendeReduz, VsaAnf.ReduzAb, VsaAnf.ArtGroeID, VsaAnf.MaxBestellmenge, VsaAnf.KeineWebBestellung, KdArtiNeu.ID AS KdArtiIDNeu
  FROM VsaAnf
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  JOIN @ArtiMapEW AS ArtiMapEW ON KdArti.ArtikelID = ArtiMapEW.ArtikelIDAlt
  JOIN KdArti AS KdArtiNeu ON KdArti.KundenID = KdArtiNeu.KundenID AND ArtiMapEW.ArtikelIDNeu = KdArtiNeu.ArtikelID AND KdArti.Variante = KdArtiNeu.Variante
) AS VsaAnfMap ([Status], VsaID, AbteilID, KdArtiID, Liefern1, Liefern2, Liefern3, Liefern4, Liefern5, Liefern6, Liefern7, SollPuffer, NormMenge, Art, Ungueltig, UngueltigBis, LeasingStop, MitInventur, Bestand, BestandKostenlos, AusstehendeReduz, ReduzAb, ArtGroeID, MaxBestellmenge, KeineWebBestellung, KdArtiIDNeu)
ON VsaAnf.VsaID = VsaAnfMap.VsaID AND VsaAnf.KdArtiID = VsaAnfMap.KdArtiIDNeu AND VsaAnf.ArtGroeID = VsaAnfMap.ArtGroeID
WHEN NOT MATCHED THEN
  INSERT ([Status], VsaID, AbteilID, KdArtiID, Liefern1, Liefern2, Liefern3, Liefern4, Liefern5, Liefern6, Liefern7, SollPuffer, NormMenge, Art, Ungueltig, UngueltigBis, LeasingStop, MitInventur, Bestand, BestandKostenlos, AusstehendeReduz, ReduzAb, ArtGroeID, MaxBestellmenge, KeineWebBestellung)
  VALUES (VsaAnfMap.[Status], VsaAnfMap.VsaID, VsaAnfMap.AbteilID, VsaAnfMap.KdArtiIDNeu, VsaAnfMap.Liefern1, VsaAnfMap.Liefern2, VsaAnfMap.Liefern3, VsaAnfMap.Liefern4, VsaAnfMap.Liefern5, VsaAnfMap.Liefern6, VsaAnfMap.Liefern7, VsaAnfMap.SollPuffer, VsaAnfMap.NormMenge, VsaAnfMap.Art, VsaAnfMap.Ungueltig, VsaAnfMap.UngueltigBis, VsaAnfMap.LeasingStop, VsaAnfMap.MitInventur, VsaAnfMap.Bestand, VsaAnfMap.BestandKostenlos, VsaAnfMap.AusstehendeReduz, VsaAnfMap.ReduzAb, VsaAnfMap.ArtGroeID, VsaAnfMap.MaxBestellmenge, VsaAnfMap.KeineWebBestellung);

PRINT(N'Old VsaAnf inactive');

UPDATE VsaAnf SET Status = N'I'
WHERE KdArtiID IN (
    SELECT KdArti.ID
    FROM KdArti
    JOIN @ArtiMapEW AS ArtiMap ON KdArti.ArtikelID = ArtiMap.ArtikelIDAlt
  )
  AND VsaAnf.Status != N'I';

GO

/* Count-IT */

/*
MERGE INTO LaundryAutomation.dbo.SalesianerChip USING (
  SELECT OPTeile.ID, OPTeile.Code, OPTeile.ArtikelID, OPTeile.ArtGroeID, Article.ArticleID
  FROM [SALADVPSQLC1A1.salres.com].Salesianer_Test.dbo._EWTeileForCIT
  JOIN [SALADVPSQLC1A1.salres.com].Salesianer_Test.dbo.OPTeile ON _EWTeileForCIT.OPTeileID = OPTeile.ID
  JOIN [SALADVPSQLC1A1.salres.com].Salesianer_Test.dbo.Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN LaundryAutomation.dbo.Article ON Article.ArticleNumber = Artikel.ArtikelNr COLLATE Latin1_General_CI_AS
) EWTeile (ID, Code, ArtikelID, ArtGroeID, ArticleID)
ON SalesianerChip.Sgtin96HexCode = EWTeile.Code COLLATE Latin1_General_CI_AS
WHEN MATCHED THEN
  UPDATE SET ArticleID = EWTeile.ArticleID
WHEN NOT MATCHED THEN
  INSERT (ArticleID, Sgtin96HexCode, IsEncoded, Created, LastUpdated)
  VALUES (EWTeile.ArticleID, EWTeile.Code, CAST(0 AS bit), GETDATE(), GETDATE());

GO
*/