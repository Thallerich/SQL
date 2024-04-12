CREATE OR ALTER FUNCTION [sapbw].[func_GetKdArti](@Datum date)
RETURNS TABLE 
AS RETURN (
  WITH Umlauf AS (
    SELECT _Umlauf.Datum, _Umlauf.ArtGroeID, _Umlauf.VsaID, SUM(_Umlauf.Umlauf) AS Umlauf
    FROM Salesianer.dbo._Umlauf
    WHERE _Umlauf.Datum = (SELECT MAX(_Umlauf.Datum) FROM Salesianer.dbo._Umlauf WHERE _Umlauf.Datum <= @Datum)
    GROUP BY _Umlauf.Datum, _Umlauf.ArtGroeID, _Umlauf.VsaID
  )
  SELECT Umlauf.Datum,
    Kunden.ID AS KundenID,
    Kunden.KdNr,
    Vsa.ID AS VsaID,
    Vsa.VsaNr,
    KdArti.ID AS KdArtiID,
    Artikel.ID AS ArtikelID,
    UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)) AS Artikel,
    Artikel.ArtikelNr,
    ArtGroe.ID AS ArtGroeID,
    ArtGroe.Groesse,
    Variante = 
    CASE 
      WHEN KdArti.VariantBez LIKE N'%(GEF-A)%' THEN N'GEF-A'
      WHEN KdArti.VariantBez LIKE N'%(GEF-H)%' THEN N'GEF-H'
      WHEN KdArti.VariantBez LIKE N'%(GEF-1)%' THEN N'GEF-1'
      WHEN KdArti.VariantBez LIKE N'%(GEF-3)%' THEN N'GEF-3'
      WHEN KdArti.VariantBez LIKE N'%(GEF-4)%' THEN N'GEF-4'
      WHEN KdArti.VariantBez LIKE N'%(HANG)%' THEN N'HANG'
      WHEN KdArti.VariantBez LIKE N'%(UNGEF)%' THEN N'UNGEF'
      WHEN KdArti.VariantBez LIKE N'%(1W)%' THEN N'1W'
      WHEN KdArti.VariantBez LIKE N'%(2W)%' THEN N'2W'
      WHEN KdArti.VariantBez LIKE N'%(3W)%' THEN N'3W'
      WHEN KdArti.VariantBez LIKE N'%(4W)%' THEN N'4W'
      WHEN KdArti.VariantBez LIKE N'%(12W)%' THEN N'12W'
      WHEN KdArti.VariantBez LIKE N'%(24W)%' THEN N'24W'
      WHEN KdArti.VariantBez LIKE N'%(8W)%' THEN N'8W'
      WHEN KdArti.VariantBez LIKE N'%(99W)%' THEN N'99W'
      WHEN KdArti.VariantBez LIKE N'%(6W)%' THEN N'6W'
      WHEN KdArti.VariantBez LIKE N'%(26W)%' THEN N'26W'
      WHEN KdArti.VariantBez LIKE N'%(16W)%' THEN N'16W'
      WHEN KdArti.VariantBez LIKE N'%(32W)%' THEN N'32W'
      WHEN KdArti.VariantBez LIKE N'%(52W)%' THEN N'52W'
      WHEN KdArti.VariantBez LIKE N'%(SPEZWN)%' THEN N'SPEZWN'
      WHEN KdArti.VariantBez LIKE N'%(SPL-A)%' THEN N'SPL-A'
      WHEN KdArti.VariantBez LIKE N'%(SPL-H)%' THEN N'SPL-H'
      WHEN KdArti.VariantBez LIKE N'%(CHEM)%' THEN N'CHEM'
      WHEN KdArti.VariantBez LIKE N'%(FOLIE)%' THEN N'FOLIE'
      WHEN KdArti.VariantBez LIKE N'%(GYN)%' THEN N'GYN'
      WHEN KdArti.VariantBez LIKE N'%(MTLKA)%' THEN N'MTLKA'
      WHEN KdArti.VariantBez LIKE N'%(QUER)%' THEN N'QUER'
      WHEN KdArti.VariantBez LIKE N'%(OBEN)%' THEN N'OBEN'
      WHEN KdArti.VariantBez LIKE N'%(ET)%' THEN N'ET'
      WHEN KdArti.VariantBez LIKE N'%(RUDI)%' THEN N'RUDI'
      WHEN KdArti.VariantBez LIKE N'%(LAENGS)%' THEN N'LAENGS'
      WHEN KdArti.VariantBez LIKE N'%(AUVA)%' THEN N'AUVA'
      WHEN KdArti.VariantBez LIKE N'%(KORNB)%' THEN N'KORNB'
      WHEN KdArti.VariantBez LIKE N'%(KE)' THEN N'KE'
      WHEN KdArti.VariantBez LIKE N'%(KE-HA)%' THEN N'KE-HA'
      WHEN KdArti.VariantBez LIKE N'%(KE-H)%' THEN N'KE-H'
      WHEN KdArti.VariantBez LIKE N'%(EXPR)%' THEN N'EXPR'
      WHEN KdArti.VariantBez LIKE N'%(VE/100)%' THEN N'VE/100'
      WHEN KdArti.VariantBez LIKE N'%(-)%' THEN N'-'
      ELSE KdArti.Variante
    END,
    KdArti.Variante AS Variante_Orig,
    IIF(Expedition.SuchCode = N'SALESIANER MIET' OR Expedition.Bez LIKE N'BU SMA%', SUBSTRING(Expedition.Bez, CHARINDEX(N' ', Expedition.Bez, 1) + 1, CHARINDEX(N':', Expedition.Bez, 1) - CHARINDEX(N' ', Expedition.Bez, 1) - 1), Expedition.SuchCode) AS Expedition,
    IIF(Produktion.SuchCode = N'SALESIANER MIET' OR Produktion.Bez LIKE N'BU SMA%', SUBSTRING(Produktion.Bez, CHARINDEX(N' ', Produktion.Bez, 1) + 1, CHARINDEX(N':', Produktion.Bez, 1) - CHARINDEX(N' ', Produktion.Bez, 1) - 1), Produktion.SuchCode) AS Produktion,
    PrListKdArtiID = IIF(KdArti.WaschPreisPrListKdArtiID > 0, KdArti.WaschPreisPrListKdArtiID, KdArti.LeasPreisPrListKdArtiID),
    CAST(IIF(KdArti.LeasPreisPrListKdArtiID > 0 OR KdArti.WaschPreisPrListKdArtiID > 0, 1, 0) AS bit) AS Preisliste,
    Umlauf.Umlauf,
    IIF(ME.ID < 0, N'ST', ME.IsoCode) AS ME,
    VertragWae.IsoCode AS Vertragswährung,
    RechWae.IsoCode AS Rechnungswährung,
    FirmaWae.IsoCode AS Firmenwährung,
    KdArti.VkPreis AS VKPreis_VTW,
    KdArti.SonderPreis AS Sonderpreis_VTW,
    KdArti.WaschPreis AS Waschpreis_VTW,
    LeasPreis.LeasPreisProWo AS Leasingpreis_VTW,
    KdArti.BasisRestwert AS Basisrestwert_VTW,
    KdArti.GesamtRestwert AS Gesamtrestwert_VTW,
    FirmaWae_VKPreis.NachPreis AS VKPreis_HRW,
    FirmaWae_SonderPreis.NachPreis AS Sonderpreis_HRW,
    FirmaWae_WaschPreis.NachPreis AS Waschpreis_HRW,
    FirmaWae_LeasPreis.NachPreis AS Leasingpreis_HRW,
    FirmaWae_Basisrestwert.NachPreis AS Basisrestwert_HRW,
    FirmaWae_Gesamtrestwert.NachPreis AS Gesamtrestwert_HRW,
    EURWae_VKPreis.NachPreis AS VKPreis_EUR,
    EURWae_SonderPreis.NachPreis AS Sonderpreis_EUR,
    EURWae_WaschPreis.NachPreis AS Waschpreis_EUR,
    EURWae_LeasPreis.NachPreis AS Leasingpreis_EUR,
    EURWae_Basisrestwert.NachPreis AS Basisrestwert_EUR,
    EURWae_Gesamtrestwert.NachPreis AS Gesamtrestwert_EUR,
    KdArti.Status,
    KdArti.VariantBez,
    Firma.ID AS FirmaID,
    FirmaWae.ID AS WaeID
  FROM Salesianer.dbo.KdArti
  JOIN Salesianer.dbo.Kunden ON KdArti.KundenID = Kunden.ID
  JOIN Salesianer.dbo.Firma ON Kunden.FirmaID = Firma.ID
  JOIN Salesianer.dbo.Vsa ON Vsa.KundenID = Kunden.ID
  JOIN Salesianer.dbo.Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Salesianer.dbo.ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
  JOIN Salesianer.dbo.KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN Salesianer.dbo.StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
  JOIN Salesianer.dbo.Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
  JOIN Salesianer.dbo.Standort AS Expedition ON StandBer.ExpeditionID = Expedition.ID
  JOIN Salesianer.dbo.ME ON Artikel.MEID = ME.ID
  JOIN Salesianer.dbo.Wae AS VertragWae ON Kunden.VertragWaeID = VertragWae.ID
  JOIN Salesianer.dbo.Wae AS RechWae ON Kunden.RechWaeID = RechWae.ID
  JOIN Salesianer.dbo.Wae AS FirmaWae ON Firma.WaeID = FirmaWae.ID
  JOIN Umlauf ON Umlauf.ArtGroeID = ArtGroe.ID AND Umlauf.VsaID = Vsa.ID
  CROSS APPLY Salesianer.dbo.advFunc_GetLeasPreisProWo(KdArti.ID) AS LeasPreis
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, FirmaWae.ID, KdArti.VkPreis, Umlauf.Datum) AS FirmaWae_VKPreis
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, FirmaWae.ID, KdArti.SonderPreis, Umlauf.Datum) AS FirmaWae_SonderPreis
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, FirmaWae.ID, KdArti.WaschPreis, Umlauf.Datum) AS FirmaWae_WaschPreis
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, FirmaWae.ID, LeasPreis.LeasPreisProWo, Umlauf.Datum) AS FirmaWae_LeasPreis
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, FirmaWae.ID, KdArti.BasisRestwert, Umlauf.Datum) AS FirmaWae_Basisrestwert
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, FirmaWae.ID, KdArti.GesamtRestwert, Umlauf.Datum) AS FirmaWae_Gesamtrestwert
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, (SELECT ID FROM Salesianer.dbo.Wae WHERE Code = N'EUR4'), KdArti.VkPreis, Umlauf.Datum) AS EURWae_VKPreis
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, (SELECT ID FROM Salesianer.dbo.Wae WHERE Code = N'EUR4'), KdArti.SonderPreis, Umlauf.Datum) AS EURWae_SonderPreis
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, (SELECT ID FROM Salesianer.dbo.Wae WHERE Code = N'EUR4'), KdArti.WaschPreis, Umlauf.Datum) AS EURWae_WaschPreis
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, (SELECT ID FROM Salesianer.dbo.Wae WHERE Code = N'EUR4'), LeasPreis.LeasPreisProWo, Umlauf.Datum) AS EURWae_LeasPreis
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, (SELECT ID FROM Salesianer.dbo.Wae WHERE Code = N'EUR4'), KdArti.BasisRestwert, Umlauf.Datum) AS EURWae_Basisrestwert
  CROSS APPLY Salesianer.dbo.advFunc_ConvertExchangeRate(VertragWae.ID, (SELECT ID FROM Salesianer.dbo.Wae WHERE Code = N'EUR4'), KdArti.GesamtRestwert, Umlauf.Datum) AS EURWae_Gesamtrestwert
  WHERE Artikel.ArtiTypeID = 1
    AND Kunden.AdrArtID = 1
)