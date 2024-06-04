SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Traeger.Traeger AS TrägerNr,
  Traeger.PersNr AS Personalnummer,
  Traeger.Vorname,
  Traeger.Nachname,
  Vsa.Bez AS Versandanschrift,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  EinzHist.Barcode,
  EinzHist.AbmeldDat AS [Abmelde-Datum],
  IIF(RPoType.RPoTypeBez$LAN$ != N'Restwerte', LTRIM(REPLACE(RPoType.RPoTypeBez$LAN$, N'Restwerte', N'')), RPoType.RPoTypeBez$LAN$) AS Berechnungsgrund,
  TeilSoFa.EPreis AS Restwert,
  RechKo.RechNr AS Rechnungsnummer,
  RechKo.RechDat AS Rechnungsdatum
FROM TeilSoFa
JOIN RechPo ON TeilSoFa.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN RPoType ON TeilSoFa.RPoTypeID = RPoType.ID
WHERE RechKo.ID = $RECHKOID$;