SELECT rechko.RechNr,
  rechko.RechDat,
  kunden.KdNr,
  Kunden.Name1,
  Kunden.Name2,
  abteil.abteilung KoSt,
  abteil.bez Kostenstelle,
  artikel.ArtikelNr,
  artikel.Artikelbez$LAN$ Bezeichnung,
  kdarti.Variante AS V,
  kdarti.VariantBez AS Variante,
  RpoType.RpoTypeBez$LAN$ Typ,
  SUM(rechpo.Menge1 + rechpo.Menge2 + rechpo.Menge3 + rechpo.Menge4 + rechpo.Menge5 + rechpo.Menge6) AS Menge,
  rechpo.EPreis StckPr,
  SUM(rechpo.GPreis) PosPr,
  RechKo.RechNr AS BelegNr,
  RechKo.RechDat AS BelegDat
FROM kdarti,
  artikel,
  rechko,
  rechpo,
  abteil,
  kunden,
  rpotype
WHERE rechpo.rechkoid = rechko.id
  AND rpotype.id = rechpo.rpotypeID
  AND kdarti.id = rechpo.kdartiid
  AND artikel.id = kdarti.artikelid
  AND abteil.id = rechpo.abteilid
  AND kunden.id = rechko.kundenid
  AND rechko.id = $RECHKOID$
GROUP BY rechko.RechNr,
  rechko.RechDat,
  kunden.KdNr,
  Kunden.Name1,
  Kunden.Name2,
  abteil.abteilung,
  abteil.bez,
  artikel.ArtikelNr,
  artikel.Artikelbez$LAN$,
  kdarti.Variante,
  kdarti.VariantBez,
  RpoType.RpoTypeBez$LAN$,
  rechpo.EPreis;