WITH LEScan AS (
  SELECT Scans.*
  FROM Scans
  WHERE Scans.ZielNrID = 41
),
PatchScan AS (
  SELECT Scans.*
  FROM Scans
  WHERE Scans.ZielNrID = 7
),
WashScan AS (
  SELECT Scans.*
  FROM Scans
  WHERE Scans.Menge = -1
)
SELECT Kunden.KdNr, ISNULL(Kunden.SuchCode, N'') AS Kunde, Traeger.Traeger AS TraegerNr, ISNULL(Traeger.Vorname, N'') AS Vorname, ISNULL(Traeger.Nachname, N'') AS Nachname, Artikel.ArtikelNr, ISNULL(Artikel.ArtikelBez, N'') AS Artikelbezeichnung, Teile.Barcode, [Status].StatusBez AS Teilestatus, Teile.ErstDatum AS [Erstauslieferung], MAX(LEScan.[DateTime]) AS [Lager-Endkontrolle], MAX(InitPatch.[DateTime]) AS [erster Patchzeitpunkt], MAX(RePatch.[DateTime]) AS [letzter Patchzeitpunkt], Mitarbei.Name AS [letzter Patch-User], (
  SELECT COUNT(WashScan.ID)
  FROM WashScan
  WHERE WashScan.TeileID = Teile.ID
    AND WashScan.DateTime BETWEEN MAX(InitPatch.DateTime) AND MAX(RePatch.DateTime)
) AS [Anzahl Wäschen zwischen Patchen]
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN [Status] ON Teile.[Status] = [Status].[Status] AND [Status].Tabelle = N'TEILE'
JOIN LEScan ON LEScan.TeileID = Teile.ID
JOIN PatchScan AS InitPatch ON InitPatch.TeileID = Teile.ID AND InitPatch.[DateTime] <= LEScan.[DateTime]
JOIN PatchScan AS RePatch ON RePatch.TeileID = Teile.ID AND RePatch.[DateTime] > LEScan.[DateTime]
JOIN Mitarbei ON RePatch.AnlageUserID_ = Mitarbei.ID
WHERE Teile.Entnommen = 1
  AND Teile.ErstDatum >= N'2018-01-01'
GROUP BY Teile.ID, Kunden.KdNr, ISNULL(Kunden.SuchCode, N''), Traeger.Traeger, ISNULL(Traeger.Vorname, N''), ISNULL(Traeger.Nachname, N''), Artikel.ArtikelNr, ISNULL(Artikel.ArtikelBez, N''), Teile.Barcode, [Status].StatusBez, Teile.ErstDatum, Mitarbei.Name;