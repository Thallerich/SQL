DECLARE @EinzTeilToVsa TABLE (
  EinzTeilID int,
  VsaID int,
  Zeitpunkt datetime2
);

BEGIN TRANSACTION;

  INSERT INTO Scans (EinzTeilID, [DateTime], ActionsID, ZielNrID, ArbPlatzID, Menge, LsPoID, AnfPoID, VsaID)
  OUTPUT inserted.EinzTeilID, inserted.VsaID, inserted.[DateTime]
  INTO @EinzTeilToVsa (EinzTeilID, VsaID, Zeitpunkt)
  SELECT EinzTeil.ID AS EinzTeilID, __CITNachtrag.QueueTimestamp, 102 AS ActionsID, 257 AS ZielNrID, 1659 AS ArbPlatzID, -1 AS Menge, LsPo.ID AS LsPoID, AnfPo.ID AS AnfPoID, AnfKo.VsaID
  FROM Salesianer.dbo.__CITNachtrag
  JOIN EinzTeil ON __CITNachtrag.Sgtin96HexCode COLLATE Latin1_General_CS_AS = EinzTeil.Code
  JOIN AnfKo ON CAST(__CITNachtrag.PackingNumber AS nvarchar) = AnfKo.AuftragsNr
  JOIN AnfPo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
  JOIN LsPo ON LsPo.KdArtiID = KdArti.ID AND LsPo.LsKoID = AnfKo.LsKoID AND LsPo.ArtGroeID = AnfPo.ArtGroeID
  WHERE EinzTeil.LastScanTime < __CITNachtrag.QueueTimestamp
    AND KdArti.ArtikelID = EinzTeil.ArtikelID
    AND AnfPo.ArtGroeID = EinzTeil.ArtGroeID;

  UPDATE EinzTeil SET VsaID = ETtV.VsaID, LastActionsID = 102, LastScanTime = ETtV.Zeitpunkt, LastScanToKunde = ETtV.Zeitpunkt, ZielNrID = 257
  FROM @EinzTeilToVsa AS ETtV
  WHERE ETtV.EinzTeilID = EinzTeil.ID;

COMMIT;