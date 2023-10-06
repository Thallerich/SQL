WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Traeger.Traeger AS TrägerNr,
  Traeger.Vorname,
  Traeger.Nachname,
  Abteil.Abteilung,
  Vsa.VsaNr,
  Vsa.Bez AS [Vsa-Bezeichnung],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  Artikel.EKPreis,
  EinzHist.Barcode,
  Teilestatus.StatusBez AS [Status des Teils],
  EinzHist.Eingang1,
  EinzHist.Ausgang1,
  EinzHist.Indienst,
  Week.Woche AS Erstwoche,
  IIF(EinzHist.Status IN (N'Z', N'V', N'X', N'Y') OR (EinzHist.Einzug < CONVERT(DATE, GETDATE())), 0, IIF((EinzHist.AusDienst = '' OR EinzHist.AusDienst IS NULL), RWCalc.RestwertInfo, IIF($1$ < EinzHist.AusDienst, RWCalc.RestWertInfo, EinzHist.AusDRestW))) AS RestWert, DATEDIFF(day, ISNULL(EinzHist.Ausgang1, CONVERT(DATE, GETDATE())), CONVERT(DATE, GETDATE())) AS BeimKundeSeitTagen
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
CROSS APPLY funcGetRestwert(EinzHist.ID, $1$, 1) AS RWCalc
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON EinzHist.Status = Teilestatus.Status
JOIN Week ON DATEADD(day, EinzTeil.AnzTageImLager, EinzTeil.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE Kunden.ID = $ID$
  AND Artikel.Status != N'B'
  AND (EinzHist.Ausdienst = N'' OR EinzHist.Ausdienst IS NULL)
  AND EinzHist.Status != N'5'
  AND Traeger.Altenheim = 0
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
ORDER BY TrägerNr, Nachname, ArtikelNr, Größe;