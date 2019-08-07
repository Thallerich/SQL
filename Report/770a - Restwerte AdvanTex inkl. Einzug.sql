DECLARE @Woche CHAR(7) = $1$;

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
  Teile.Erstwoche,
  IIF(Teile.Status IN ('Z', 'V', 'X', 'Y') OR (Teile.Einzug < CONVERT(DATE, GETDATE())), 0, IIF((Teile.AusDienst = '' OR Teile.AusDienst IS NULL), RWCalc.RestwertInfo, IIF(@Woche < Teile.AusDienst, RWCalc.RestWertInfo, Teile.AusDRestW))) AS RestWert,
  DATEDIFF(day, ISNULL(Teile.Ausgang1, CONVERT(DATE, GETDATE())), CONVERT(DATE, GETDATE())) AS BeimKundeSeitTagen
FROM Teile
CROSS APPLY funcGetRestwert(Teile.ID, @Woche, 1) AS RWCalc
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
WHERE Kunden.ID = $ID$
  AND Artikel.Status <> 'B'
  AND (Teile.Ausdienst = '' OR Teile.Ausdienst IS NULL)
  AND Teile.Status <> '5'
  AND Traeger.Altenheim = $FALSE$
ORDER BY TrägerNr, Nachname, ArtikelNr, Größe;