DECLARE @Woche nchar(7);

SELECT @Woche = [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat;

SELECT Traeger.Vorname,
  Traeger.Nachname,
  Abteil.Abteilung,
  Vsa.VsaNr,
  Vsa.Bez AS VSA,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  Artikel.EKPreis,
  EinzHist.Barcode,
  EinzHist.Eingang1,
  EinzHist.Ausgang1,
  EinzHist.Indienst,
  EinzTeil.Erstwoche,
  RwCalc.RestWertInfo AS Restwert,
  DATEDIFF(day, ISNULL(einzhist.Ausgang1, CONVERT(DATE, GETDATE())), CONVERT(DATE, GETDATE())) AS BeimKundeSeitTagen
FROM EinzHist
CROSS APPLY funcGetRestwert(EinzHist.ID, @Woche, 1) AS RwCalc
JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
WHERE Kunden.ID = $ID$
  AND Artikel.Status != N'B'
  AND EinzHist.Ausdienst IS NULL
  AND EinzHist.Status != N'5'
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
  AND EinzTeil.AltenheimModus = 0;