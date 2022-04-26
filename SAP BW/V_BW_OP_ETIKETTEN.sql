ALTER VIEW [sapbw].[V_BW_OP_ETIKETTEN] AS
  WITH SetStatus
  AS (
    SELECT OPEtiKo.ID AS OPEtiKoID, OPEtiKo.EtiNr, COUNT(OPEtiPo.ID) AS Anz, SUM(IIF(CAST(OPEtiKo.AusleseZeitpunkt AS date) = CAST(EinzTeil.LastScanTime AS date), 0, 1)) AS Retour
    FROM Salesianer.dbo.OPEtiKo
    JOIN Salesianer.dbo.OPEtiPo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
    JOIN Salesianer.dbo.EinzTeil ON OPEtiPo.EinzTeilID = EinzTeil.ID
    WHERE OPEtiKo.AusleseZeitpunkt >= N'2019-01-01 00:00:00'
    GROUP BY OPEtiko.ID, OPEtiKo.EtiNr
  ),
  OPScans AS (
    SELECT OPEtiPo.ID AS OPEtiPoID, OPEtiKo.ID AS OPEtiKoID, Scans.EinzTeilID, MIN(Scans.[DateTime]) AS Zeitpunkt, OPEtiKo.AusleseZeitpunkt
    FROM Salesianer.dbo.Scans
    JOIN Salesianer.dbo.OPEtiPo ON Scans.EinzTeilID = OPEtiPo.EinzTeilID
    JOIN Salesianer.dbo.OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
    WHERE Scans.[DateTime] >= '2019-01-01 00:00:00'
      AND Scans.ActionsID IN (100, 1)
      AND Scans.Menge = 1
      AND Scans.EinzTeilID != -1
      AND OPEtiKo.AusleseZeitpunkt >= '2019-01-01 00:00:00'
      AND Scans.[DateTime] > Opetiko.AusleseZeitpunkt
    GROUP BY OPEtiPo.ID, OPEtiKo.ID, Scans.EinzTeilID, OPEtiKo.Auslesezeitpunkt
  )
  SELECT OPScans.OPEtiPoID, --> Schlüssel
    SetStatus.EtiNr, --> Text
    --> Status R & U in SAP einschränken
    OPScans.EinzTeilID AS Chipcode,
    --> in Transformation
    SetStatus.Retour,
    IIF(SetStatus.Anz - SetStatus.Retour = 0, 0, 1) AS Statusoffen, -- 0 = Alle Mehrweg retour 1 = fehlende Teile
    OPScans.Zeitpunkt
  FROM SetStatus
  JOIN OPScans ON OPScans.OPEtiKoID = SetStatus.OPEtiKoID;
  
GO