SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, OPTeile.ErstWoche, OPTeile.EkGrundAkt AS EKPreis, Rechko.RechNr, RechKo.RechDat AS Rechnungsdatum, Kunden.KdNr, Kunden.SuchCode AS Kunde, Firma.Bez AS Firma, OPTeile.Code AS Chipcode, OPTeile.AusDRestwert AS RestwertVerrechnet
FROM OPTeile, RechPo, RechKo, Artikel, Kunden, Firma
WHERE OPTeile.RechPoID = RechPo.ID
  AND RechPo.RechKoID = RechKo.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND RechKo.KundenID = Kunden.ID
  AND Kunden.FirmaID = Firma.ID
  AND OPTeile.Status = 'W'
  AND OPTeile.RechPoID > 0
  AND NOT EXISTS (
    SELECT R.*
    FROM RechPo R
    WHERE R.OriginalRechPoID = RechPo.ID
  );