/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ TRUNCATE TABLE _IT85364;                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

CREATE TABLE #PePoProzent (
  PePoID int PRIMARY KEY CLUSTERED,
  PeProzent numeric(18,4)
);

GO

DECLARE @pekobez nvarchar(40) = N'PE Juli 2024 V MED';

INSERT INTO #PePoProzent (PePoID, PeProzent)
SELECT DISTINCT PePo.ID, _IT85364.Prozent * 100
FROM PePo WITH (UPDLOCK)
JOIN PeKo ON PePo.PeKoID = PeKo.ID
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN _IT85364 ON Kunden.KdNr = _IT85364.KdNr AND Vertrag.Nr = _IT85364.[Vertrags-Nr]
WHERE PeKo.Bez = @pekobez
  AND PeKo.[Status] = N'G'
  AND PeKo.WirksamDatum = N'2024-07-01'
  AND PePo.PeProzent != _IT85364.Prozent * 100;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE PePo SET PeProzent = #PePoProzent.PeProzent
    FROM #PePoProzent
    WHERE #PePoProzent.PePoID = PePo.ID;
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;

GO

DROP TABLE #PePoProzent;
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE #PeMemo;
GO

CREATE TABLE #PeMemo (
  KundenID int PRIMARY KEY CLUSTERED,
  Memo nvarchar(max)
);

GO

DECLARE @pekoid int = 1322;

INSERT INTO #PeMemo (KundenID, Memo)
SELECT DISTINCT Vertrag.KundenID, N'Die rollierende Inflation der letzten 12 Monate zeigt einen Wert von ' + FORMAT(PePo.PeProzent, N'#.00') + N' %. Um dieser Kostenentwicklung zu begegnen, werden wir unsere Preise mit Wirkung per Juli 2024 um den Prozentsatz von ' + FORMAT(PePo.PeProzent, N'#.00') + N' % erhöhen.' AS Memo
FROM PePo
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
WHERE PePo.PeKoID = @pekoid
  AND PePo.PeProzent != 2.21
  AND PePo.PeProzent != 0;

INSERT INTO #PeMemo (KundenID, Memo)
SELECT DISTINCT Vertrag.KundenID, N'Gemäß letztem Beschluss der Paritätischen Kommission, erhöhen wir unsere Preise mit Wirkung zum 1.7.2024 um 2,21 %.' AS Memo
FROM PePo
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
WHERE PePo.PeKoID = @pekoid
  AND PePo.PeProzent = 2.21
  AND PePo.PeProzent != 0;

UPDATE VsaTexte SET Memo = #PeMemo.Memo
FROM #PeMemo
WHERE #PeMemo.KundenID = VsaTexte.KundenID
  AND VsaTexte.TextArtID = 13
  AND VsaTexte.VonDatum = N'2024-07-25'
  --AND VsaTexte.AnlageUserID_ = 9012688;
/* 
INSERT INTO VsaTexte (KundenID, TextArtID, Memo, VonDatum, BisDatum)
SELECT #PeMemo.KundenID, 13, #PeMemo.Memo, '2024-07-25', '2024-08-25'
FROM #PeMemo
WHERE NOT EXISTS (
  SELECT VsaTexte.*
  FROM VsaTexte
  WHERE VsaTexte.KundenID = #PeMemo.KundenID
    AND VsaTexte.TextArtID = 13
    AND VsaTexte.VonDatum = N'2024-07-25'
);
 */
GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++                                                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DELETE FROM VsaTexte
WHERE ID IN (
  SELECT VsaTexte.ID
  FROM VsaTexte
  JOIN Kunden ON VsaTexte.KundenID = Kunden.ID
  JOIN Holding ON Kunden.HoldingID = Holding.ID
  WHERE VsaTexte.TextArtID = 13
    AND CAST(GETDATE() AS date) BETWEEN VsaTexte.VonDatum AND VsaTexte.BisDatum
    AND Holding.Holding IN ('CARI', 'CARIB', '*CARIO', 'CARIK', 'MUEN', 'SALK', 'STOC', 'NEUN', 'LPPH', 'AMSTE', 'HOCHE', 'HOLLA', 'SCHEI', 'NPEN', 'PULM', 'NOEGKK', 'DIAW', 'AUVA')
);