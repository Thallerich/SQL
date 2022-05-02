ALTER VIEW [sapbw].[V_BW_OP_ETIKETTEN] AS
  WITH SetStatus
  AS (
    SELECT OPEtiKo.ID AS OPEtiKoID, COUNT(OPEtiPo.ID) AS Anz, SUM(IIF(CAST(OPEtiKo.AusleseZeitpunkt AS date) = CAST(EinzTeil.LastScanTime AS date), 0, 1)) AS Retour
    FROM Salesianer.dbo.OPEtiKo
    JOIN Salesianer.dbo.OPEtiPo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
    JOIN Salesianer.dbo.EinzTeil ON OPEtiPo.EinzTeilID = EinzTeil.ID
    WHERE OPEtiKo.AusleseZeitpunkt > N'2019-01-01 00:00:00'
      AND OPEtiKo.AusleseZeitpunkt IS NOT NULL
      AND OPEtiPo.EinzTeilID > 0
    GROUP BY OPEtiko.ID, OPEtiKo.EtiNr
  )
  SELECT OPEtiPo.ID, --> Schlüssel
    OPEtiKo.EtiNr, --> Text
    --> Status R & U in SAP einschränken
    EinzTeil.ID AS Chipcode,
    --> in Transformation
    SetStatus.Retour,
    IIF(SetStatus.Anz - SetStatus.Retour = 0, 0, 1) AS Statusoffen, -- 0 = Alle Mehrweg retour 1 = fehlende Teile
    MIN(Scans.[DateTime]) AS Zeitpunkt  -- erstes Einlesen nach dem Auslesen
  FROM Salesianer.dbo.OPEtiPo
  JOIN Salesianer.dbo.OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
  JOIN Salesianer.dbo.EinzTeil ON OPEtiPo.EinzTeilID = EinzTeil.ID
  JOIN SetStatus ON SetStatus.OPEtiKoID = OPEtiKo.ID
  JOIN Salesianer.dbo.Scans ON Scans.EinzTeilID = EinzTeil.ID
  WHERE OPEtiPo.EinzTeilID > 0
    AND OPEtiKo.AusleseZeitpunkt IS NOT NULL
    AND OPEtiKo.AusleseZeitpunkt > N'2019-01-01 00:00:00'
    AND Scans.ActionsID IN (100, 1)
    AND Scans.Menge = 1
    AND Scans.[DateTime] > OPEtiKo.AusleseZeitpunkt
  GROUP BY OPEtiPo.ID, OPEtiKo.EtiNr, EinzTeil.iD, SetStatus.Retour, IIF(SetStatus.Anz - SetStatus.Retour = 0, 0, 1);
  
GO