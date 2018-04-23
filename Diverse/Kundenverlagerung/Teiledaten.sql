SELECT Teile.Barcode,
  Teile.RentomatChip,
  CAST(IIF(LagerArt.DauerBarcode = 0 AND Teile.Status < N'N', 1, 0) AS bit) AS Dummybarcode, --bekommt das Teil später einen Dauerbarcode?
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse,
  Teile.Eingang1 AS [LetzterEingang],
  Teile.Ausgang1 AS [LetzterAusgang],
  Teile.RuecklaufG AS [AnzahlWaeschen],
  Teile.AnzRepairG AS [AnzahlReparaturen],
  Teile.ErstDatum AS [ErstesEinsatzdatum],
  Teile.Erstwoche AS [ErsteWocheAbschreibung],
  Teile.AlterInfo AS [AlterInWochen],
  [Status].StatusBez AS [Status],
  IIF(Teile.AusdienstDat IS NOT NULL, Teile.AusdRestw, Teile.RestwertInfo) AS Restwert,
  LiefArt.LiefArt AS AuslieferartKZ,
  LiefArt.LiefArtBez AS Auslieferart,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  NULL AS Abteilung,
  Vsa.VsaNr,
  Vsa.Bez AS [Vsa-Bezeichnung],
  Abteil.Abteilung AS KsSt,
  Abteil.Bez AS [KsStBez],
  Traeger.Traeger AS TraegerNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Standort.SuchCode AS [internProdBetrieb],
  HStandort.SuchCode AS ProdBetrieb
FROM [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Teile
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.LiefArt ON KdArti.LiefArtID = LiefArt.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Abteil ON Traeger.AbteilID = Abteil.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Vsa ON Traeger.VsaID = Vsa.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Kunden ON Vsa.KundenID = Kunden.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Artikel.BereichID = StandBer.BereichID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Standort ON StandBer.ProduktionID = Standort.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Standort AS HStandort ON Kunden.StandortID = HStandort.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.[Status] ON Teile.[Status] = [Status].[Status] AND [Status].Tabelle = N'TEILE'
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.Firma ON Kunden.FirmaID = Firma.ID
JOIN [ATENADVANTEX01.WOZABAL.INT\ADVANTEX].Wozabal.dbo.LagerArt ON Teile.LagerArtID = LagerArt.ID
WHERE Traeger.Altenheim = 0
  AND Firma.SuchCode <> N'STX'
  AND Teile.[Status] NOT IN (N'5', N'X', N'XM', N'Y');