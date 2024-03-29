SELECT EinzHist.Barcode, Kunden.KdNr, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Vsa.Bez AS VSA, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Grö0e, EinzHist.AbmeldDat AS [Abmelde-Datum], /* Einsatz.EinsatzBez AS [Abmelde-Grund], */ IIF(RPoType.RPoTypeBez != N'Restwerte', LTRIM(REPLACE(RPoType.RPoTypeBez, N'Restwerte', N'')), RPoType.RPoTypeBez) AS Berechnungsgrund, CAST(TeilSoFa.EPreis AS float) AS Restwert
FROM TeilSoFa
JOIN RechPo ON TeilSoFa.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
--JOIN Einsatz ON EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
JOIN RPoType ON TeilSoFa.RPoTypeID = RPoType.ID
WHERE RechKo.RechNr = 30303276
  AND EinzHist.Barcode IN (SELECT Barcode COLLATE Latin1_General_CS_AS FROM Salesianer.dbo._VOEST_KVPTeile);

GO

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Vsa.Bez AS VSA, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Barcode, EinzHist.AbmeldDat AS [Abmelde-Datum], IIF(RPoType.RPoTypeBez != N'Restwerte', LTRIM(REPLACE(RPoType.RPoTypeBez, N'Restwerte', N'')), RPoType.RPoTypeBez) AS Berechnungsgrund, CAST(TeilSoFa.EPreis AS float) AS Restwert, RechKo.RechNr, RechKo.RechDat, IIF(TeilSoFa.RechPoGutschriftID > 0, GRechKo.RechNr, NULL) AS [Gutschrift RechNr], IIF(TeilSoFa.RechPoGutschriftID > 0, GRechKo.RechDat, NULL) AS [Gutschrift Datum]
FROM TeilSoFa
JOIN RechPo ON TeilSoFa.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN RechPo GRechPo ON TeilSoFa.RechPoGutschriftID = GRechPo.ID
JOIN RechKo GRechKo ON GRechPo.RechKoID = GRechKo.ID
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN RPoType ON TeilSoFa.RPoTypeID = RPoType.ID
WHERE TeilSoFa.RechPoID > 0
  AND RechKo.RechDat > N'2023-01-01'
  AND Kunden.HoldingID = (SELECT Holding.ID FROM Holding WHERE Holding.Holding = N'VOESLE');

GO

/*
UPDATE TeilSoFa SET TeilSoFa.Status = N'T'
WHERE TeilSoFa.ID IN (
    SELECT TeilSoFa.ID
    FROM TeilSoFa
    JOIN RechPo ON TeilSoFa.RechPoID = RechPo.ID
    JOIN RechKo ON RechPo.RechKoID = RechKo.ID
    JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
    WHERE RechKo.RechNr = 30303276
      AND EinzHist.Barcode IN (SELECT Barcode COLLATE Latin1_General_CS_AS FROM Salesianer.dbo._VOEST_KVPTeile)
  )
  AND TeilSoFa.Status = N'P';

GO
*/