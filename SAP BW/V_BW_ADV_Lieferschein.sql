CREATE OR ALTER VIEW [dbo].[V_BW_ADV_Lieferschein] AS
  SELECT LsKo.LsNr,
    LsKo.Datum,
    LSStatus = LsKo.[Status],
    Kunden.KdNr,
    Vsa.VsaNr,
    RgNr =
      CASE
        WHEN LsPo.RechPoID > 0 THEN RechKo.RechNr
        WHEN LsPo.RechPoID < -1 THEN (
          SELECT MIN(RechKo.RechNr)
          FROM Salesianer.dbo.RechPo
          JOIN Salesianer.dbo.RechKo ON RechPo.RechKoID = RechKo.ID
          JOIN Salesianer.dbo.KdArti AS CaseKdArti ON RechPo.KdArtiID = CaseKdArti.ID
          WHERE RechKo.KundenID = Kunden.ID
            AND RechPo.VsaID = Vsa.ID
            AND CaseKdArti.ArtikelID = Artikel.ID
            AND CaseKdArti.ID = KdArti.ID
            AND RechPo.AbteilID = LsPo.AbteilID
            AND LsKo.Datum BETWEEN RechKo.VonDatum AND RechKo.BisDatum
            AND RechKo.Art = N'R'
        )
        ELSE NULL
      END,
    Rechnungsposition =
      CASE
        WHEN LsPo.RechPoID > 0 THEN LsPo.RechPoID
        WHEN LsPo.RechPoID < -1 THEN ISNULL((
          SELECT MIN(RechPo.ID)
          FROM Salesianer.dbo.RechPo
          JOIN Salesianer.dbo.RechKo ON RechPo.RechKoID = RechKo.ID
          JOIN Salesianer.dbo.KdArti AS CaseKdArti ON RechPo.KdArtiID = CaseKdArti.ID
          WHERE RechKo.KundenID = Kunden.ID
            AND RechPo.VsaID = Vsa.ID
            AND CaseKdArti.ArtikelID = Artikel.ID
            AND CasekdArti.ID = KdArti.ID
            AND RechPo.AbteilID = LsPo.AbteilID
            AND LsKo.Datum BETWEEN RechKo.VonDatum AND RechKo.BisDatum
            AND RechKo.Art = N'R'
        ), LsPo.RechPoID)
        ELSE LsPo.RechPoID
      END,
    Expedition = IIF(Expedition.SuchCode = N'SALESIANER MIET', SUBSTRING(Expedition.Bez, CHARINDEX(N' ', Expedition.Bez, 1) + 1, CHARINDEX(N':', Expedition.Bez, 1) - CHARINDEX(N' ', Expedition.Bez, 1) - 1), IIF(Expedition.Bez LIKE N'%ehem. Asten%', N'SMA', Expedition.SuchCode)),
    Produktion = IIF(Produktion.SuchCode = N'SALESIANER MIET', SUBSTRING(Produktion.Bez, CHARINDEX(N' ', Produktion.Bez, 1) + 1, CHARINDEX(N':', Produktion.Bez, 1) - CHARINDEX(N' ', Produktion.Bez, 1) - 1), IIF(Produktion.Bez LIKE N'%ehem. Asten%', N'SMA', Produktion.SuchCode)),
    KTRBetrieb = CONCAT(CAST(Produktion.FibuNr AS nvarchar), COALESCE((
      SELECT RPoKonto.AbwKostenstelle
      FROM Salesianer.dbo.RechPo
      JOIN Salesianer.dbo.RechKo ON RechPo.RechKoID = RechKo.ID
      JOIN Salesianer.dbo.Kunden ON RechKo.KundenID = Kunden.ID
      LEFT JOIN Salesianer.dbo.RPoKonto ON RechPo.MwStId = RPoKonto.MwStID AND RechPo.RPoTypeID = RPoKonto.RPoTypeID AND RechPo.BereichId = RPoKonto.BereichID AND RechPo.ArtGruID = RPoKonto.ArtGruID AND RechKo.FirmaID = RPoKonto.FirmaID AND Kunden.KdGfID = RPoKonto.KdGfID AND COALESCE(RPoKontoMitBranche.BrancheID, RPoKontoOhneBranche.BrancheID) = RPoKonto.BrancheID
      WHERE RechPo.ID = LsPo.RechPoID
    ), RPoKontoMitBranche.AbwKostenstelle, RPoKontoOhneBranche.AbwKostenstelle)),
    ArtikelNr = UPPER(Artikel.ArtikelNr) + ISNULL(N'-' + IIF(ArtGroe.Groesse = N'-', NULL, ArtGroe.Groesse), N''),
    LsMenge = LsPo.Menge,
    Einheit = IIF(ME.IsoCode = N'-', N'ST', ME.IsoCode),
    LSKO_Liefergrund = IIF(LsPo.LsKoGruID = -1, N'1-', CAST(LsPo.LsKoGruID AS nvarchar)),
    Kostl = IIF(LsPo.AbteilID = -1, N'', Abteil.Abteilung),
    Betreuer = 
      CASE
        WHEN Betreuer.ID = -1 THEN N'??????'
        WHEN Betreuer.MaNr = N'190002' THEN N'BAYELE'
        WHEN Betreuer.MaNr = N'231' THEN N'BENNCL'
        WHEN Betreuer.MaNr = N'189' THEN N'FUERTH'
        WHEN Betreuer.MaNr = N'3502' THEN N'GRIEWA'
        WHEN Betreuer.MaNr IN (N'208', N'3503') THEN N'KOESSA'
        WHEN Betreuer.MaNr = '1' THEN N'KV'
        WHEN Betreuer.MaNr = '3504' THEN N'TSCHDA'
        WHEN Betreuer.MaNr = '235' THEN Betreuer.Nachname
        WHEN Betreuer.MaNr = '40' THEN N'ZAHRWO'
        WHEN Betreuer.Initialen IS NULL THEN LEFT(REPLACE(REPLACE(REPLACE(UPPER(Betreuer.Nachname), N'Ü', N'UE'), N'Ö', N'OE'), N'Ä', N'AE'), 4) + LEFT(REPLACE(REPLACE(REPLACE(UPPER(Betreuer.Vorname), N'Ü', N'UE'), N'Ö', N'OE'), N'Ä', N'AE'), 2)
        ELSE UPPER(Betreuer.Initialen)
      END,
    LsPoID = LsPo.ID,
    LsPo.Kostenlos
FROM Salesianer.dbo.LsPo
JOIN Salesianer.dbo.LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Salesianer.dbo.Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Salesianer.dbo.Standort AS Expedition ON Fahrt.ExpeditionID = Expedition.ID
JOIN Salesianer.dbo.Standort AS Produktion ON LsPo.ProduktionID = Produktion.ID
JOIN Salesianer.dbo.KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Salesianer.dbo.Kunden ON KdArti.KundenID = Kunden.ID
JOIN Salesianer.dbo.Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Salesianer.dbo.ArtGroe ON LsPo.ArtGroeID = ArtGroe.ID
JOIN Salesianer.dbo.Me ON Artikel.MeID = Me.ID
JOIN Salesianer.dbo.Vsa ON LsKo.VsaID = Vsa.ID
JOIN Salesianer.dbo.Abteil ON LsPo.AbteilID = Abteil.ID
JOIN Salesianer.dbo.KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Salesianer.dbo.Mitarbei AS Betreuer ON KdBer.BetreuerID = Betreuer.ID
JOIN Salesianer.dbo.RechPo ON LsPo.RechPoID = RechPo.ID
JOIN Salesianer.dbo.RechKo ON RechPo.RechKoID = RechKo.ID
LEFT JOIN Salesianer.dbo.RPoKonto AS RPoKontoMitBranche ON Artikel.BereichID = RPoKontoMitBranche.BereichID AND Kunden.FirmaID = RPoKontoMitBranche.FirmaID AND Kunden.KdGfID = RPoKontoMitBranche.KdGfID AND Kunden.MwStID = RPoKontoMitBranche.MwStID AND Kunden.BrancheID = RPoKontoMitBranche.BrancheID AND Artikel.ArtGruID = RPoKontoMitBranche.ArtGruID AND RPoKontoMitBranche.RPoTypeID = 2
LEFT JOIN Salesianer.dbo.RPoKonto AS RPoKontoOhneBranche ON Artikel.BereichID = RPoKontoOhneBranche.BereichID AND Kunden.FirmaID = RPoKontoOhneBranche.FirmaID AND Kunden.KdGfID = RPoKontoOhneBranche.KdGfID AND Kunden.MwStID = RPoKontoOhneBranche.MwStID AND RPoKontoOhneBranche.BrancheID = -1 AND Artikel.ArtGruID = RPoKontoOhneBranche.ArtGruID AND RPoKontoOhneBranche.RPoTypeID = 2
LEFT JOIN Salesianer.dbo.Konten ON RPoKontoMitBranche.KontenID = Konten.ID
WHERE LsKo.Datum > N'2022-01-01'
  AND LsKo.Status > N'O'
  AND LsPo.LsKoGruID != 40;