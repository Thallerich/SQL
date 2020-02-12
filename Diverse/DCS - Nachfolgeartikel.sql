DECLARE @ErsatzMap TABLE (
  Alt nchar(15) COLLATE Latin1_General_CS_AS,
  Neu nchar(15) COLLATE Latin1_General_CS_AS
);

DECLARE @KdMap TABLE (
  KundenID int,
  AltKdArtiID int,
  NeuKdArtiID int,
  NeuArtikelID int,
  RentomatID int
);

DECLARE @KdNr int = 23046;

INSERT INTO @ErsatzMap VALUES (N'2501037012', N'25010370121'), (N'2503003011', N'25030030111'), (N'2505000304', N'25050003041'), (N'2505000305', N'25050003051'), (N'2505004418', N'25050044181'), (N'2505004419', N'25050044191'), (N'2505004420', N'25050044201'), (N'2505069505', N'25050695051'), (N'2505501012', N'25055010121'), (N'2505512010', N'25055120101'), (N'2505512220', N'25055122201'), (N'3003448102', N'30034481021'), (N'3060605005', N'30606050051'), (N'3080101005', N'30801010051'), (N'3258100802', N'32581008021'), (N'3258101322', N'32581013221'), (N'3030101001', N'30301010011'), (N'3080101001', N'30801010011'), (N'3080101002', N'30801010021'), (N'2507026270', N'25070262701'), (N'3140103005', N'31401030051'), (N'2501037010', N'25010370101'), (N'2507001001', N'25070010011');

WITH NeuArtikel AS (
  SELECT KdArti.ArtikelID, KdArti.KundenID, KdArti.ID AS KdArtiID, EM.Alt
  FROM KdArti
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN @ErsatzMap AS EM ON EM.Neu = Artikel.ArtikelNr
)
INSERT INTO @KdMap
SELECT Kunden.ID AS KundenID, KdArti.ID AS AltKdArtiID, NeuArtikel.KdArtiID AS NeuKdArtiID, NeuArtikel.ArtikelID AS NeuArtikelID, Rentomat.ID AS RentomatID
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Rentomat ON Rentomat.KundenID = Kunden.ID
JOIN NeuArtikel ON NeuArtikel.Alt = Artikel.ArtikelNr AND NeuArtikel.KundenID = Kunden.ID
JOIN @ErsatzMap AS ErsatzMap ON ErsatzMap.Alt = Artikel.ArtikelNr
WHERE Rentomat.Interface = N'DCSvoll'
  AND Kunden.KdNr = @KdNr;

/* SELECT Kunden.KdNr, Kunden.SuchCode, ArtikelAlt.ArtikelNr, ArtikelAlt.ArtikelBez, ArtikelNeu.ArtikelNr, ArtikelNeu.ArtikelBez, KdArti.Umlauf
FROM @KdMap AS KdMap
JOIN Kunden ON KdMap.KundenID = Kunden.ID
JOIN KdArti ON KdMap.AltKdArtiID = KdArti.ID
JOIN Artikel AS ArtikelAlt ON KdArti.ArtikelID = ArtikelAlt.ID
JOIN Artikel AS ArtikelNeu ON KdMap.NeuArtikelID = ArtikelNeu.ID
WHERE KdArti.Umlauf > 0; */


--SELECT TraeArti.VsaID, TraeArti.TraegerID, NeuArtGroe.ID AS ArtGroeID, KdMap.NeuKdArtiID, 0 AS Menge
/* UPDATE TraeArti SET TraeArti.KdArtiID = KdMap.NeuKdArtiID, TraeArti.ArtGroeID = NeuArtGroe.ID
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN @KdMap AS KdMap ON KdMap.KundenID = Vsa.KundenID AND KdMap.RentomatID = Vsa.RentomatID AND TraeArti.KdArtiID = KdMap.AltKdArtiID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN ArtGroe AS NeuArtGroe ON NeuArtGroe.ArtikelID = KdMap.NeuArtikelID AND NeuArtGroe.Groesse = ArtGroe.Groesse
WHERE Traeger.RentoArtID > 0
  AND NOT EXISTS (
    SELECT TA.*
    FROM TraeArti AS TA
    WHERE TA.KdArtiID = KdMap.NeuKdArtiID
      AND TA.ArtGroeID = NeuArtGroe.ID
      AND TA.TraegerID = TraeArti.TraegerID
  ); */


--SELECT DISTINCT KdAusArt.KdAusstaID, KdMap.NeuKdArtiID, Pos = (SELECT MAX(KAA.Pos) FROM KdAusArt AS KAA WHERE KAA.KdAusstaID = KdAussta.ID) + 10 * DENSE_RANK() OVER (PARTITION BY KdAusArt.KdAusstaID ORDER BY KdAusArt.Pos), KdAusArt.Menge
UPDATE KdAusArt SET KdAusArt.KdArtiID = KdMap.NeuKdArtiID
FROM KdAusArt
JOIN KdAussta ON KdAusArt.KdAusstaID = KdAussta.ID
JOIN @KdMap AS KdMap ON KdAussta.KundenID = KdMap.KundenID AND KdAusArt.KdArtiID = KdMap.AltKdArtiID
WHERE NOT EXISTS (
  SELECT KA.*
  FROM KdAusArt AS KA
  WHERE KA.KdAusstaID = KdAusArt.KdAusstaID
    AND KA.KdArtiID = KdMap.NeuKdArtiID
);

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
WHERE Kunden.KdNr = 31065
  AND EXISTS (
    SELECT Teile.*
    FROM Teile
    JOIN Vsa ON Teile.VsaID = Vsa.ID
    JOIN Traeger ON Teile.TraegerID = Traeger.ID
    WHERE Vsa.RentomatID = 40
      AND Teile.Status = N'Q'
      AND Traeger.RentoArtID = 3
      AND Teile.KdArtiID = KdArti.ID
  )
  AND NOT EXISTS (
    SELECT KdAusArt.*
    FROM KdAusArt
    WHERE KdAusArt.KdArtiID = KdArti.ID
  );

SELECT KdAussta.Bez, KdAusArt.KdAusstaID, KdAusArt.KdArtiID, KdAusArt.Pos, KdAusArt.Menge
FROM KdAusArt
JOIN KdAussta ON KdAusArt.KdAusstaID = KdAussta.ID
JOIN RentoCod ON RentoCod.KdAusstaID = KdAussta.ID
JOIN KdArti ON KdAusArt.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RentoCod.RentomatID = 40
  AND Artikel.ArtikelNr = N'2507001001';

INSERT INTO KdAusArt (KdAusstaID, KdArtiID, Pos, Menge)
VALUES (5375, 34891012, 340, 2);