WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
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
  Teile.Barcode,
  Teilestatus.StatusBez AS [Status des Teils],
  Teile.Eingang1,
  Teile.Ausgang1,
  Teile.Indienst,
  Week.Woche AS Erstwoche,
  IIF(Teile.Status IN (N'Z', N'V', N'X', N'Y') OR (Teile.Einzug < CONVERT(DATE, GETDATE())), 0, IIF((Teile.AusDienst = '' OR Teile.AusDienst IS NULL), RWCalc.RestwertInfo, IIF($1$ < Teile.AusDienst, RWCalc.RestWertInfo, Teile.AusDRestW))) AS RestWert, DATEDIFF(day, ISNULL(Teile.Ausgang1, CONVERT(DATE, GETDATE())), CONVERT(DATE, GETDATE())) AS BeimKundeSeitTagen
FROM Teile
CROSS APPLY funcGetRestwert(Teile.ID, $1$, 1) AS RWCalc
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
JOIN Week ON DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
WHERE Kunden.ID = $ID$
  AND Artikel.Status != N'B'
  AND (Teile.Ausdienst = N'' OR Teile.Ausdienst IS NULL)
  AND Teile.Status != N'5'
  AND Traeger.Altenheim = 0
ORDER BY TrägerNr, Nachname, ArtikelNr, Größe;