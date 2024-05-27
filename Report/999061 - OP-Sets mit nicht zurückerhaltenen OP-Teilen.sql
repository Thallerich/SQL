/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: TempTablePrep                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #OpSetsNichtKomplettZurueck;

WITH SetStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'OPETIKO'
)
SELECT OPEtiKo.ID AS OPEtiKoID, OPEtiKo.EtiNr, SetStatus.StatusBez AS [Status], OPEtiKo.VerfallDatum, OPEtiKo.ArtikelID, OPEtiKo.VsaID, OPEtiKo.OPChargeID, OPEtiKo.LsPoID, LsKo.LsNr, LsKo.Datum AS Lieferdatum
INTO #OpSetsNichtKomplettZurueck
FROM OPEtiKo
JOIN SetStatus ON OPEtiKo.[Status] = SetStatus.[Status]
JOIN LsPo ON OPEtiKo.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
WHERE OPEtiKo.[Status] IN (N'R', N'U')  /* Sets vollständig beim Kunden (R) oder bereits teilweise retourniert (U) */
  AND OPEtiKo.LsPoID > 0
  AND LsKo.Datum >= $1$
  AND OPEtiKo.VerfallDatum <= $2$
  AND EXISTS (
    SELECT OPEtiPo.*
    FROM OPEtiPo
    WHERE OPEtiPo.OPEtiKoID = OPEtiKo.ID
  );

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Reportdaten                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @curweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);

WITH OPTeilStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZTEIL'
)
SELECT Expedition.Bez AS [Standort Expedition],
  Produktion.Bez AS [Standort Produktion],
  x.EtiNr,
  x.VerfallDatum,
  Artikel.ArtikelNr AS [Set-ArtikelNr],
  Artikel.ArtikelBez$LAN$ AS [Set-Artikelbezeichnung],
  x.[Status] AS [Set-Status],
  x.LsNr,
  x.Lieferdatum,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kunden.Name1 AS [Adresszeile 1],
  Vsa.VsaNr,
  Vsa.SuchCode AS [Vsa-Stichwort],
  Vsa.Bez AS [Vsa-Bezeichnung],
  EinzTeil.Code AS [Code OP-Teil],
  OPTeilArtikel.ArtikelNr AS [ArtikelNr OP-Teil],
  OPTeilArtikel.ArtikelBez$LAN$ AS [Artikelbezeichnung OP-Teil],
  OPTeilStatus.StatusBez AS [Status OP-Teil],
  EinzTeil.RuecklaufG AS [Anzahl Wäschen],
  OPTeilArtikel.EkPreis AS [EK-Preis OP-Teil],
  (OPTeilArtikel.EKPreis/IIF(OPTeilArtikel.MaxWaschen = 0, 1, OPTeilArtikel.MaxWaschen)) * (OPTeilArtikel.MaxWaschen - EinzTeil.RuecklaufG) * IIF(OPTeilArtikel.MaxWaschen = 0, 0, 1) AS [Restwert Kunden-unabhängig],
  fRWOP.RestwertInfo [Restwert lt. RW-Konfiguration letzter Kunde]
FROM #OpSetsNichtKomplettZurueck AS x
JOIN Artikel ON x.ArtikelID = Artikel.ID
JOIN Vsa ON x.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN OPEtiKo ON x.OPEtiKoID = OPEtiKo.ID
JOIN OPEtiPo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
JOIN EinzTeil ON OPEtiPo.EinzTeilID = EinzTeil.ID AND EinzTeil.LastOPEtiKoID = OPEtiKo.ID
CROSS APPLY funcGetRestwertOP(EinzTeil.ID, @curweek, 1) AS fRWOP
JOIN Artikel AS OPTeilArtikel ON EinzTeil.ArtikelID = OPTeilArtikel.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Artikel.BereichID
JOIN Standort AS Expedition ON StandBer.ExpeditionID = Expedition.ID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN OPTeilStatus ON EinzTeil.Status = OPTeilStatus.Status
WHERE EinzTeil.LastActionsID = 102 -- OP Ausgelesen
ORDER BY x.Lieferdatum, x.EtiNr;