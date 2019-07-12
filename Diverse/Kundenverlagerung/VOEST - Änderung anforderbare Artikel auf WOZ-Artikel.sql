DECLARE @ArtiMap TABLE (
  ArtNrSAL nchar(15) COLLATE Latin1_General_CS_AS,
  ArtNrWOZ nchar(15) COLLATE Latin1_General_CS_AS
);

INSERT INTO @ArtiMap VALUES 
  (N'820100', N'101212010001'),
  (N'820200', N'104416028001'),
  (N'81010B', N'104416025235');

--SELECT VsaAnf.ID, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], KdArtiWOZ.ID AS KdArtiID_WOZ, ArtikelWOZ.ArtikelNr AS ArtikelNr_WOZ, ArtikelWOZ.ArtikelBez AS Artikelbezeichnung_WOZ, VsaAnf.ArtGroeID, ArtGroe.ID AS ArtGroeID_WOZ
UPDATE VsaAnf SET VsaAnf.KdArtiID = KdArtiWOZ.ID, VsaAnf.ArtGroeID = ArtGroe.ID
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN @ArtiMap AS ArtiMap ON Artikel.ArtikelNr = ArtiMap.ArtNrSAL
JOIN Artikel AS ArtikelWOZ ON ArtikelWOZ.ArtikelNr = ArtiMap.ArtNrWOZ
JOIN KdArti AS KdArtiWOZ ON KdArtiWOZ.ArtikelID = ArtikelWOZ.ID AND KdArtiWOZ.KundenID = Kunden.ID
JOIN ArtGroe ON ArtikelWOZ.ID = ArtGroe.ArtikelID
WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE');