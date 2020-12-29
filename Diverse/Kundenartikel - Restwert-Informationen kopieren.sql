DECLARE @ReferenzKunde int = 202013;
DECLARE @ZielKunde int = <<KdNr>>;
DECLARE @ForceUpdate bit = 0;        -- Bestehende Basis-Restwerte beim Zielkunden überschreiben?
DECLARE @AfaWochenKopieren bit = 0;  -- Sollen die AfaWochen mit kopiert werden?

DECLARE @ReferenzArtikel TABLE (
  ArtikelID int,
  Variante nvarchar(2) COLLATE Latin1_General_CS_AS,
  BasisRestwert money,
  AfaWochen int
);

DECLARE @Aktualisiert TABLE (
  ArtikelID int,
  KundenID int,
  Variante nvarchar(2) COLLATE Latin1_General_CS_AS,
  VariantBez nvarchar(60) COLLATE Latin1_General_CS_AS,
  BasisRestwertAlt money,
  AfaWochenAlt int,
  BasisRestwertNeu money,
  AfaWochenNeu int
);

INSERT INTO @ReferenzArtikel (ArtikelID, Variante, BasisRestwert, AfaWochen)
SELECT KdArti.ArtikelID, KdArti.Variante, KdArti.BasisRestwert, KdArti.AfaWochen
FROM KdArti
WHERE KdArti.KundenID = (
    SELECT Kunden.ID
    FROM Kunden
    WHERE Kunden.KdNr = @ReferenzKunde
  );

IF @AfaWochenKopieren = 0
  BEGIN
    UPDATE KdArti SET BasisRestwert = ReferenzArtikel.BasisRestwert
    OUTPUT inserted.ArtikelID, inserted.KundenID, inserted.Variante, deleted.BasisRestwert, deleted.AfaWochen, inserted.BasisRestwert, inserted.AfaWochen
    INTO @Aktualisiert (ArtikelID, KundenID, Variante, BasisRestwertAlt, AfaWochenAlt, BasisRestwertNeu, AfaWochenNeu)
    FROM KdArti
    JOIN @ReferenzArtikel AS ReferenzArtikel ON ReferenzArtikel.ArtikelID = KdArti.ArtikelID AND ReferenzArtikel.Variante = KdArti.Variante
    WHERE KdArti.KundenID = (
        SELECT Kunden.ID
        FROM Kunden
        WHERE Kunden.KdNr = @ZielKunde
      )
      AND KdArti.BasisRestwert != ReferenzArtikel.BasisRestwert
      AND (@ForceUpdate = 1 OR (@ForceUpdate = 0 AND KdArti.BasisRestwert = 0));
  END;
ELSE
  BEGIN
    UPDATE KdArti SET AfaWochen = ReferenzArtikel.AfaWochen, BasisRestwert = ReferenzArtikel.BasisRestwert
    OUTPUT inserted.ArtikelID, inserted.KundenID, inserted.Variante, deleted.BasisRestwert, deleted.AfaWochen, inserted.BasisRestwert, inserted.AfaWochen
    INTO @Aktualisiert (ArtikelID, KundenID, Variante, BasisRestwertAlt, AfaWochenAlt, BasisRestwertNeu, AfaWochenNeu)
    FROM KdArti
    JOIN @ReferenzArtikel AS ReferenzArtikel ON ReferenzArtikel.ArtikelID = KdArti.ArtikelID AND ReferenzArtikel.Variante = KdArti.Variante
    WHERE KdArti.KundenID = (
        SELECT Kunden.ID
        FROM Kunden
        WHERE Kunden.KdNr = @ZielKunde
      )
      AND (KdArti.AfaWochen != ReferenzArtikel.AfaWochen OR KdArti.BasisRestwert != ReferenzArtikel.BasisRestwert)
      AND (@ForceUpdate = 1 OR (@ForceUpdate = 0 AND KdArti.BasisRestwert = 0));
  END;

IF @AfaWochenKopieren = 0
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, AktualisierteArtikel.Variante, AktualisierteArtikel.VariantBez AS Variantenbezeichnung, AktualisierteArtikel.BasisRestwertAlt AS [Basis-Restwert Alt], AktualisierteArtikel.BasisRestwertNeu AS [Basis-Restwert Neu]
  FROM @Aktualisiert AS AktualisierteArtikel
  JOIN Artikel ON AktualisierteArtikel.ArtikelID = Artikel.ID
  JOIN Kunden ON AktualisierteArtikel.KundenID = Kunden.ID
  ORDER BY ArtikelNr ASC;
ELSE
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, AktualisierteArtikel.Variante, AktualisierteArtikel.VariantBez AS Variantenbezeichnung, AktualisierteArtikel.BasisRestwertAlt AS [Basis-Restwert Alt], AktualisierteArtikel.AfaWochenAlt AS [AfA-Wochen Alt], AktualisierteArtikel.AfaWochenNeu AS [AfA-Wochen Neu], AktualisierteArtikel.BasisRestwertNeu AS [Basis-Restwert Neu]
  FROM @Aktualisiert AS AktualisierteArtikel
  JOIN Artikel ON AktualisierteArtikel.ArtikelID = Artikel.ID
  JOIN Kunden ON AktualisierteArtikel.KundenID = Kunden.ID
  ORDER BY ArtikelNr ASC;