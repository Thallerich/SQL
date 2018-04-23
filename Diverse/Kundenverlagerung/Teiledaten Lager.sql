SELECT TeileLag.Barcode,
  CAST(0 AS bit) AS Dummybarcode,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse,
  NULL AS [Letzter Eingang],
  NULL AS [Letzter Ausgang],
  TeileLag.AnzWaschen AS [Anzahl Wäschen],
  TeileLag.AnzRepair AS [Anzahl Reparaturen],
  TeileLag.ErstDatum AS [Erstes Einsatzdatum],
  TeileLag.ErstWoche AS [Erste Woche Abschreibung],
  TeileLag.AnzTageImLager,
  [Status].StatusBez AS [aktueller Status],
  TeileLag.Restwert,
  LiefArt.LiefArt AS AuslieferartKZ,
  LiefArt.LiefArtBez AS Auslieferart,
  NULL AS KdNr,
  NULL AS VsaNr,
  NULL AS [Vsa-Bezeichnung],
  NULL AS Abteilung,
  NULL AS KsSt,
  NULL AS [Kostenstellen-Bezeichnung],
  NULL AS TraegerNr,
  Standort.SuchCode AS [Lagerstandort]
FROM [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.TeileLag
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo..ArtGroe ON TeileLag.ArtGroeID = ArtGroe.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo..Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo..LiefArt ON Artikel.LiefArtID = LiefArt.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo..LagerArt ON TeileLag.LagerArtID = LagerArt.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo..Standort ON LagerArt.LagerID = Standort.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo..[Status] ON TeileLag.[Status] = [Status].[Status] AND [Status].Tabelle = N'TEILELAG'
WHERE TeileLag.[Status] <> N'Y';
