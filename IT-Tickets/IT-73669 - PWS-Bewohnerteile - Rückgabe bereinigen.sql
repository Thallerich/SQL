DISABLE TRIGGER ALL ON EinzHist

GO

DECLARE @kdgfid int = (SELECT KdGf.ID FROM KdGf WHERE KdGf.KurzBez = N'MED');

DECLARE @Hauptstandort TABLE (
  StandortID int,
  StandortKuerzel nchar(4) COLLATE Latin1_General_CS_AS
);

INSERT INTO @Hauptstandort (StandortKuerzel)
VALUES (N'WOEN'), (N'WOLI');

UPDATE @Hauptstandort SET StandortID = Standort.ID
FROM Standort
WHERE Standort.SuchCode = [@Hauptstandort].StandortKuerzel;

UPDATE EinzHist SET [Status] = N'Q', Abmeldung = NULL, AbmeldDat = NULL, Ausdienst = NULL, AusdienstDat = NULL, AusdienstGrund = NULL, Einzug = NULL
WHERE ID IN (
  SELECT EinzHist.ID
  FROM EinzTeil
  JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
  JOIN Eigentum ON KdArti.EigentumID = Eigentum.ID
  WHERE Kunden.KdGFID = @kdgfid
    AND Kunden.StandortID IN (SELECT StandortID FROM @Hauptstandort)
    AND EinzTeil.AltenheimModus = 1
    AND EinzHist.Status = N'W'
    AND Eigentum.RueckgabeBew = 0
    AND EinzHist.EinzHistTyp = 1
    AND EinzHist.TraeArtiID != -1
)

GO

ENABLE TRIGGER ALL ON EinzHist

GO