SELECT EinzHist.Barcode, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Vsa.Bez AS VSA, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Grö0e, EinzHist.AbmeldDat AS [Abmelde-Datum], Einsatz.EinsatzBez AS [Abmelde-Grund], IIF(RPoType.RPoTypeBez != N'Restwerte', LTRIM(REPLACE(RPoType.RPoTypeBez, N'Restwerte', N'')), RPoType.RPoTypeBez) AS Berechnungsgrund, CAST(TeilSoFa.EPreis AS float) AS Restwert
FROM TeilSoFa
JOIN RechPo ON TeilSoFa.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Einsatz ON EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
JOIN RPoType ON TeilSoFa.RPoTypeID = RPoType.ID
WHERE RechKo.RechNr = 30303276;

GO