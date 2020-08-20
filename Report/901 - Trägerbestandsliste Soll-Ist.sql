DECLARE @KundenID int = $ID$;
DECLARE @CurrentWeek nchar(7);

SET @CurrentWeek = (
  SELECT Week.Woche
  FROM Week
  WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat
);

WITH Umlaufteile AS (
  SELECT Teile.TraeArtiID, COUNT(Teile.ID) AS inBerechnung
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  WHERE Vsa.KundenID = @KundenID
    AND Teile.Kostenlos = 0
    AND Teile.AltenheimModus = 0
    AND ISNULL(Teile.Indienst, N'2099/52') <= @CurrentWeek
    AND ISNULL(Teile.Ausdienst, N'2099/52') > @CurrentWeek
  GROUP BY Teile.TraeArtiID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS [Träger-Nummer], Traeger.Nachname, Traeger.Vorname, Traeger.Titel, Traeger.PersNr AS Personalnummer, Traeger.Indienst AS Indienststellungswoche, Traeger.Ausdienst AS Außerdienststellungswoche, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, TraeArti.Menge AS Sollmenge, ISNULL(Umlaufteile.inBerechnung, 0) AS Umlauf
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
LEFT JOIN Umlaufteile ON Umlaufteile.TraeArtiID = TraeArti.ID
WHERE Kunden.ID = @KundenID
  AND (TraeArti.Menge != 0 OR Umlaufteile.inBerechnung != 0)
  AND Traeger.Status NOT IN (N'K', N'P')
ORDER BY [VSA-Nummer], Nachname, Vorname, [Träger-Nummer];