DECLARE @Woche char(7);

SET @Woche = (SELECT Week.Woche FROM Week WHERE Week.vonDat < CONVERT(date, GETDATE()) AND Week.bisDat > CONVERT(date, GETDATE()));

SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Vorname, Traeger.Nachname, Abteil.Abteilung, Vsa.VsaNr, Vsa.Bez AS VSA, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Artikel.EKPreis, Teile.Barcode, Teile.Eingang1, Teile.Ausgang1, Teile.Indienst, Week.Woche AS Erstwoche, IIF(Teile.Status IN ('Z', 'V', 'X', 'Y', 'U') OR (Teile.Einzug < CONVERT(date, GETDATE())), 0, IIF((Teile.AusDienst = '' OR Teile.AusDienst IS NULL), Teile.RestWertInfo, IIF(@Woche < Teile.AusDienst, Teile.RestWertInfo, Teile.AusDRestW))) AS RestWert, DATEDIFF(day, ISNULL(Teile.Ausgang1, CONVERT(date, GETDATE())), CONVERT(date, GETDATE())) AS BeimKundeSeitTagen
FROM Teile, Traeger, Vsa, Kunden, Abteil, Artikel, ArtGroe, Holding, Week
WHERE Teile.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Traeger.AbteilID = Abteil.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND Kunden.HoldingID = Holding.ID
  AND DATEADD(day, Teile.AnzTageImLager, Teile.ErstDatum) BETWEEN Week.VonDat AND Week.BisDat
  AND Holding.ID = $1$
  AND Artikel.Status <> N'B'
  AND (Teile.Ausdienst = N'' OR Teile.Ausdienst IS NULL)
  AND Teile.Status <> N'5'
  AND Traeger.Altenheim = 0;