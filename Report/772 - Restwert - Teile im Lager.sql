DECLARE @curweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);

WITH LagerteilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Lager.Suchcode AS [Lager-Standort],
  Lagerart.LagerartBez$LAN$ AS Lagerart,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  IIF(Kunden.KdNr = 0, NULL, Kunden.KdNr) AS [Letzte KdNr],
  Kunden.SuchCode AS [Letzter Kunde],
  Holding.Holding AS [Holding letzter Kunde],
  EinzHist.Barcode,
  LagerteilStatus.StatusBez AS [Status Lager-Teil],
  Lagerort.Lagerort,
  VertragWaeRestwert.NachPreis AS Restwert,
  Wae.ID AS Restwert_WaeID,
  EinlagerRestwert.NachPreis AS Restwert_Einlagerung,
  Wae.ID AS Restwert_Einlagerung_WaeID,
  Wae.IsoCode AS Währung,
  [hat Applikation] = CAST(IIF(EXISTS (
    SELECT TeilAppl.*
    FROM TeilAppl
    WHERE TeilAppl.EinzHistID = EinzHist.ID
  ), 1, 0) AS bit)
FROM EinzHist
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
JOIN Firma ON Lagerart.FirmaID = Firma.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN Lagerort ON EinzHist.LagerOrtID = Lagerort.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Wae ON Kunden.VertragWaeID = Wae.ID
JOIN LagerteilStatus ON EinzHist.[Status] = LagerteilStatus.[Status]
CROSS APPLY dbo.advfunc_GetRestwertIgnoreAusdRestW(EinzHist.ID, @curweek, 1) RwCalc
CROSS APPLY dbo.advFunc_ConvertExchangeRate(Firma.WaeID, Kunden.VertragWaeID, IIF(RwCalc.RestwertInfo = 0, EinzHist.RestwertInfo, RwCalc.RestwertInfo), GETDATE()) AS VertragWaeRestwert
CROSS APPLY dbo.advFunc_ConvertExchangeRate(Firma.WaeID, Kunden.VertragWaeID, EinzHist.RestwertInfo, GETDATE()) AS EinlagerRestwert
WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND EinzHist.EinzHistTyp = 2 /* Teile im Lager */
  AND EinzHist.[Status] IN (N'X', N'XE', N'XI')
  AND Lager.ID IN ($1$)
  AND Artikel.ID IN ($2$)
  AND Holding.ID IN ($3$);