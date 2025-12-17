DECLARE @Artikelharmonisierung TABLE (
  AltArtikel nchar(15) COLLATE Latin1_General_CS_AS,
  NeuArtikel nchar(15) COLLATE Latin1_General_CS_AS
);

INSERT INTO @Artikelharmonisierung
VALUES ('112606005018', 'KDT250'),
  ('112603005031', 'KD1T56');

SELECT N'ARTIKEL_HARMONISIERUNG;' + CAST(AltArtikel.ID AS nvarchar) + ';' + CAST(NeuArtikel.ID AS nvarchar)
FROM @Artikelharmonisierung AS x
JOIN Artikel AS AltArtikel ON x.AltArtikel = AltArtikel.ArtikelNr
JOIN Artikel AS NeuArtikel ON x.NeuArtikel = NeuArtikel.ArtikelNr;

SELECT N'fehlende Ersatzartikel-Definitonen' AS Typ, BasisArtikel.ArtikelNr AS Basisartikel, ArtikelErsatz.ArtikelNr AS Ersatzartikel, ArtikelErsatzNeu.ArtikelNr AS ErsatzartikelNeu
FROM ArtiKomp
JOIN Artikel AS BasisArtikel ON ArtiKomp.ArtikelID = BasisArtikel.ID
JOIN Artikel AS ArtikelErsatz ON ArtiKomp.KompArtikelID = ArtikelErsatz.ID
JOIN @Artikelharmonisierung AS x ON x.AltArtikel = ArtikelErsatz.ArtikelNr
JOIN Artikel AS ArtikelErsatzNeu ON x.NeuArtikel = ArtikelErsatzNeu.ArtikelNr
WHERE ArtiKomp.ArtiRelID = 1
  AND NOT EXISTS (
    SELECT ak.*
    FROM ArtiKomp AS ak
    WHERE ak.KompArtikelID = ArtikelErsatzNeu.ID
      AND ak.ArtikelID = ArtiKomp.ArtikelID
      AND ak.ArtiRelID = 1
  );