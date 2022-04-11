DECLARE @from datetime = DATEADD(day, 0, $2$);
DECLARE @to datetime = DATEADD(day, 1, $3$);

WITH SetStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'OPETIKO')
)
SELECT SetArtikel.ArtikelNr AS [Set-ArtikelNr],
  SetArtikel.ArtikelBez$LAN$ AS [Set-Artikelbezeichnung],
  SetArtikel.StueckGewicht AS [Gesamtgewicht in kg],
  OPEtiKo.EtiNr AS [Set-Seriennummer],
  SetStatus.StatusBez AS [Set-Status],
  OPEtiKo.PackZeitpunkt AS [Pack-Zeitpunkt],
  PackMitarbei.UserName AS [Pack-MitarbeiterNr],
  PackMitarbei.Name AS [Pack-Mitarbeiter],
  [Inhalt-ArtikelNr] =
    CASE
      WHEN OPEtiPo.EinzTeilID > 0 THEN InhaltTeil.ArtikelNr
      WHEN OPEtiPo.OPEinwegID > 0 THEN InhaltEinweg.ArtikelNr
      ELSE N'WTF!?!'
    END,
  [Inhalt-Artikelbezeichnung] = 
    CASE
      WHEN OPEtiPo.EinzTeilID > 0 THEN InhaltTeil.ArtikelBez$LAN$
      WHEN OPEtiPo.OPEinwegID > 0 THEN InhaltEinweg.ArtikelBez$LAN$
      ELSE N'WTF!?!'
    END,
  [Inhalt-Artikelgewicht] =
    CASE
      WHEN OPEtiPo.EinzTeilID > 0 THEN InhaltTeil.StueckGewicht
      WHEN OPEtiPo.OPEinwegID > 0 THEN InhaltEinweg.StueckGewicht
      ELSE N'WTF!?!'
    END,
  [Inhalt-Barcode] = 
    CASE
      WHEN OPEtiPo.EinzTeilID > 0 THEN EinzTeil.Code
      WHEN OPEtiPo.OPEinwegID > 0 THEN OPEinweg.Barcode
      ELSE N'WTF!?!'
    END,
  [Inhalt-Typ] = 
    CASE
      WHEN OPEtiPo.EinzTeilID > 0 AND (SELECT COUNT(*) FROM OPEtiKo AS o WHERE o.EtiNr = EinzTeil.Code) <= 0 THEN N'Pool-Teil'
      WHEN OPEtiPo.OPEinwegID > 0 THEN N'Einweg-Charge'
      WHEN OPEtiPo.EinzTeilID > 0 AND (SELECT COUNT(*) FROM OPEtiKo AS o WHERE o.EtiNr = EinzTeil.Code) > 0 THEN N'Set-im-Set'
      ELSE N'who knows man!'
    END,
  EinzTeil.Erstwoche,
  EinzTeil.AnzWasch AS [Anzahl Wäschen],
  [Anzahl Nachwäschen] = (
    SELECT COUNT(Scans.ID)
    FROM Scans
    WHERE Scans.EinzTeilID = EinzTeil.ID
      AND Scans.ActionsID = 105 -- OP Nachwäsche
  ),
  EinzTeil.AlterInfo AS [Alter in Wochen],
  OPSets.[Position],
  OPSets.Modus
FROM OPEtiKo
JOIN Artikel AS SetArtikel ON OPEtiKo.ArtikelID = SetArtikel.ID
JOIN SetStatus ON OPEtiKo.[Status] = SetStatus.[Status]
JOIN Mitarbei AS PackMitarbei ON OPEtiKo.PackMitarbeiID = PackMitarbei.ID
JOIN OPEtiPo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
JOIN OPSets ON OPEtiPo.OPSetsID = OPSets.ID
LEFT OUTER JOIN EinzTeil ON OPEtiPo.EinzTeilID = EinzTeil.ID AND OPEtiPo.EinzTeilID > 0
LEFT OUTER JOIN Artikel AS InhaltTeil ON EinzTeil.ArtikelID = InhaltTeil.ID
LEFT OUTER JOIN OPEinweg ON OPEtiPo.OPEinwegID = OPEinweg.ID AND OPEtiPo.OPEinwegID > 0
LEFT OUTER JOIN Artikel AS InhaltEinweg ON OPEinweg.ArtikelID = InhaltEinweg.ID
WHERE OPEtiKo.ProduktionID IN ($1$)
  AND OPEtiKo.PackZeitpunkt BETWEEN @from AND @to;