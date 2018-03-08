USE Wozabal;

SELECT Bereich.BereichBez AS Produktbereich, ArtGru.ArtGruBez AS Artikelgruppe, N'' AS [Kostenträger MED], N'' AS [Kostenträger JOB], N'' AS [Kostenträger GAST], ArtGru.Schrank, ArtGru.Sack, ArtGru.Steril, ArtGru.OpBarcode, ArtGru.Barcodiert, ArtGru.ZwingendBarcodiert, ArtGru.Container, ArtGru.SdcFolge, ArtGru.KeineErfassung, ArtGru.SackMitBarcode, ArtGru.SetImSet, ArtGru.OPSetPatchenID, ArtGru.InstrumentPatchenID, ArtGru.OPEinweg, ArtGru.NoMassWebportal, ArtGru.SetArtikel, ArtGru.UsesBKOpTeileArtGru, ArtGru.OPOhneVsa, ArtGru.OpSetBestellen
FROM ArtGru
JOIN Bereich ON ArtGru.BereichID = Bereich.ID
WHERE Bereich.ID > 0
ORDER BY Bereich.BereichBez, ArtGru.Gruppe;

SELECT DISTINCT Bereich.BereichBez AS Produktbereich, ArtGru.ArtGruBez AS [Artikelgruppe aktuell], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtiType.ArtiTypeBez AS [Artikel-Typ], [Status].StatusBez AS Artikelstatus, N'' AS [Artikelgruppe neu], IIF(OPSets.ID IS NOT NULL, N'Ja', N'') AS [Ist Set?]
FROM Artikel
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN [Status] ON Artikel.[Status] = [Status].[Status] AND [Status].Tabelle = N'ARTIKEL'
JOIN ArtiType ON Artikel.ArtiTypeID = ArtiType.ID
LEFT OUTER JOIN OPSets ON OPSets.ArtikelID = Artikel.ID
WHERE Artikel.ID > 0;