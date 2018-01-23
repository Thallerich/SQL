USE Wozabal
GO

/*
DROP TABLE IF EXISTS __ArtikelEKBMD;

CREATE TABLE __ArtikelEKBMD (
  BMDNr nchar(15) NOT NULL,
  ArtikelNr nchar(20) NOT NULL,
  EKPreis money NOT NULL,
  WAE nchar(3),
  ME nvarchar(5)
);
*/

TRUNCATE TABLE __ArtikelEKBMD;

BULK INSERT __ArtikelEKBMD
  FROM N'\\SRVATENSQL01\ArtikelEKBMD\ArtikelListe.csv'
  WITH (FORMATFILE = N'\\SRVATENSQL01\ArtikelEKBMD\__ArtikelEKBMD.xml', FIRSTROW=2)
GO

SELECT * FROM __ArtikelEKBMD;

GO