DECLARE @KdNr int = 30360;
DECLARE @Jahr int = 2018;

WITH Ausgang AS (
  SELECT Scans.*
  FROM Scans
  WHERE Scans.LsPoID > 0
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS VSANr, Vsa.Bez AS VSA, Traeger.Traeger AS TrägerNr, Traeger.Vorname, Traeger.Nachname, Abteil.Abteilung AS KsSt, Abteil.Bez AS KsStBezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Teile.Barcode, COUNT(Ausgang.ID) AS [Anzahl Wäschen]
FROM Ausgang
JOIN Teile ON Ausgang.TeileID = Teile.ID
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE Kunden.KdNr = @KdNr
  AND DATEPART(year, Ausgang.[DateTime]) = @Jahr
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Teile.Barcode;