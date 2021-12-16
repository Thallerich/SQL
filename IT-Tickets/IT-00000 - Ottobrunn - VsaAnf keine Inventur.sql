CREATE TABLE _VsaAnfNoInvOtto (
  VsaAnfID int,
  Art nchar(1) COLLATE Latin1_General_CS_AS,
  MitInventur bit
);

GO

WITH VsaAnfNoInv AS (
  SELECT VsaAnf.ID AS VsaAnfID, VsaAnf.Art, VsaAnf.MitInventur
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  WHERE Artikel.ArtikelNr IN (N'9903GE', N'9903GR', N'SW8987', N'SW8988', N'SW8982', N'SW0428', N'SW0429', N'SW0430', N'SW0431', N'SW0432', N'SW0433', N'SW0434', N'SW0435', N'SW0436', N'SW0437', N'SW0438', N'SW0439', N'SW0440', N'SW0441', N'SW0442', N'SW0443', N'SW0444', N'SW0445', N'SW0446', N'SW0447', N'SW0448', N'SW0449', N'SW0450', N'SW0451', N'SW0452', N'SW0453', N'SW0454', N'SW0455', N'SW0456', N'SW0457', N'SW0458', N'SW0459', N'SW0460', N'SW0461', N'SW0462', N'SW0463', N'SW0464', N'SW0465')
    AND Kunden.KdNr IN (10003461, 10003474, 10003466)
    AND (UPPER(VsaAnf.Art) = N'M' OR VsaAnf.MitInventur = 1)
)
UPDATE VsaAnf SET Art = N'M', MitInventur = 0
OUTPUT deleted.ID, deleted.Art, deleted.MitInventur
INTO _VsaAnfNoInvOtto (VsaAnfID, Art, MitInventur)
WHERE VsaAnf.ID IN (SELECT VsaAnfID FROM VsaAnfNoInv);

GO