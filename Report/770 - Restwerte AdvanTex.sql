DECLARE @Woche char(7);

SET @Woche = (SELECT Week.Woche FROM Week WHERE Week.vonDat < CONVERT(date, GETDATE()) AND Week.bisDat > CONVERT(date, GETDATE()));

SELECT Traeger.Vorname, Traeger.Nachname, Abteil.Abteilung, Vsa.VsaNr, Vsa.Bez AS VSA, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Artikel.EKPreis, Teile.Barcode, Teile.Eingang1, Teile.Ausgang1, Teile.Indienst, Week.Woche AS Erstwoche, IIF(Teile.Status IN ('Z', 'V', 'X', 'Y', 'U') OR (Teile.Einzug < CONVERT(date, GETDATE())), 0, IIF((Teile.AusDienst = '' OR Teile.AusDienst IS NULL), Teile.RestWertInfo, IIF(@Woche < Teile.AusDienst, Teile.RestWertInfo, Teile.AusDRestW))) AS RestWert, DATEDIFF(day, ISNULL(Teile.Ausgang1, CONVERT(date, GETDATE())), CONVERT(date, GETDATE())) AS BeimKundeSeitTagen
FROM Teile, Traeger, Vsa, Kunden, Abteil, Artikel, ArtGroe, Week
WHERE Teile.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Traeger.AbteilID = Abteil.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
  AND Kunden.ID = $ID$
  AND Artikel.Status <> 'B'
  AND (Teile.Ausdienst = '' OR Teile.Ausdienst IS NULL)
  AND Teile.Status <> '5'
  AND Traeger.Altenheim = 0;