/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Set RwConfig and AfaWochen                                                                                                ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE Kunden SET RwConfigID = 710
WHERE Kunden.HoldingID IN (SELECT ID FROM Holding WHERE Holding = N'SVAT');

UPDATE KdArti SET AfaWochen = 260
WHERE KdArti.KundenID IN (SELECT Kunden.ID FROM Kunden WHERE Kunden.HoldingID IN (SELECT ID FROM Holding WHERE Holding = N'SVAT'))
  AND KdArti.AfaWochen != 260;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Reporting                                                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH LagerteilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Lager.Suchcode AS [Lager-Standort],
  Lagerart.LagerartBez AS Lagerart,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  IIF(Kunden.KdNr = 0, NULL, Kunden.KdNr) AS [Letzte KdNr],
  Kunden.SuchCode AS [Letzter Kunde],
  Holding.Holding AS [Holding letzter Kunde],
  EinzHist.Barcode,
  LagerteilStatus.StatusBez AS [Status Lager-Teil],
  Lagerort.Lagerort,
  VertragWaeRestwert.NachPreis AS Restwert,
  Wae.ID AS Restwert_WaeID,
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
CROSS APPLY advfunc_GetRestwertIgnoreAusdRestW(EinzHist.ID, EinzHist.Ausdienst, 6) RwCalc
CROSS APPLY advFunc_ConvertExchangeRate(Firma.WaeID, Kunden.VertragWaeID, IIF(RwCalc.RestwertInfo = 0, EinzHist.RestwertInfo, RwCalc.RestwertInfo), GETDATE()) AS VertragWaeRestwert
WHERE EinzHist.ID = (SELECT EinzTeil.CurrEinzHistID FROM EinzTeil WHERE EinzTeil.ID = EinzHist.EinzTeilID)
  AND EinzHist.EinzHistTyp = 2 /* Teile im Lager */
  AND EinzHist.[Status] IN (N'X', N'XE', N'XI')
  --AND Lager.ID IN ($1$)
  --AND Artikel.ID IN ($2$)
  AND Holding.Holding = N'SVAT';