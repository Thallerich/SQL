DECLARE @Artikelharmonisierung TABLE (
  AltArtikel nchar(15) COLLATE Latin1_General_CS_AS,
  NeuArtikel nchar(15) COLLATE Latin1_General_CS_AS
);

INSERT INTO @Artikelharmonisierung
VALUES ('110620662001', '710160'),
  ('111204040001', '313700'),
  ('111228040001', '323700'),
  ('111220040001', '333700'),
  ('111290040001', '344000');

SELECT N'ARTIKEL_HARMONISIERUNG;' + CAST(AltArtikel.ID AS nvarchar) + ';' + CAST(NeuArtikel.ID AS nvarchar)
FROM @Artikelharmonisierung AS x
JOIN Artikel AS AltArtikel ON x.AltArtikel = AltArtikel.ArtikelNr
JOIN Artikel AS NeuArtikel ON x.NeuArtikel = NeuArtikel.ArtikelNr;

SELECT ArtiKomp.*
FROM ArtiKomp
JOIN Artikel AS ArtikelErsatz ON ArtiKomp.KompArtikelID = ArtikelErsatz.ID
JOIN @Artikelharmonisierung AS x ON x.AltArtikel = ArtikelErsatz.ArtikelNr
JOIN Artikel AS ArtikelErsatzNeu ON x.NeuArtikel = ArtikelErsatzNeu.ID
WHERE NOT EXISTS (
  SELECT ak.*
  FROM ArtiKomp AS ak
  WHERE ak.KompArtikelID = ArtikelErsatzNeu.ID
    AND ak.ArtikelID = ArtiKomp.ArtikelID
);