/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Trägerbestand                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @CurrentWeek nchar(7);

SET @CurrentWeek = (
  SELECT Week.Woche
  FROM Week
  WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat
);

WITH Umlaufteile AS (
  SELECT EinzHist.TraeArtiID, COUNT(EinzHist.ID) AS inBerechnung
  FROM EinzTeil
  JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  WHERE Vsa.KundenID IN ($1$)
    AND EinzHist.Kostenlos = 0
    AND EinzTeil.AltenheimModus = 0
    AND EinzHist.EinzHistTyp = 1
    AND EinzHist.PoolFkt = 0
    AND ISNULL(EinzHist.Indienst, N'2099/52') <= @CurrentWeek
    AND ISNULL(EinzHist.Ausdienst, N'2099/52') > @CurrentWeek
  GROUP BY EinzHist.TraeArtiID
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
WHERE Kunden.ID IN ($1$)
  AND (TraeArti.Menge != 0 OR Umlaufteile.inBerechnung != 0)
  AND Traeger.Status NOT IN (N'K', N'P')
ORDER BY [VSA-Nummer], Nachname, Vorname, [Träger-Nummer];


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Trägerbestand inkl. Ausstattung                                                                                           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @CurrentWeek nchar(7);

SET @CurrentWeek = (
  SELECT Week.Woche
  FROM Week
  WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat
);

WITH Umlaufteile AS (
  SELECT EinzHist.TraeArtiID, COUNT(EinzHist.ID) AS inBerechnung
  FROM EinzTeil
  JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  WHERE Vsa.KundenID IN ($1$)
    AND EinzHist.Kostenlos = 0
    AND EinzTeil.AltenheimModus = 0
    AND EinzHist.EinzHistTyp = 1
    AND EinzHist.PoolFkt = 0
    AND ISNULL(EinzHist.Indienst, N'2099/52') <= @CurrentWeek
    AND ISNULL(EinzHist.Ausdienst, N'2099/52') > @CurrentWeek
  GROUP BY EinzHist.TraeArtiID
),
Ausstattung as (
  select kdarti.id as kdartiid, kdaussta.Bez kdausbez, artikel.ArtikelBez ausartbez, Menge
  from kunden 
  join KDAUSSTA on kunden.id = kdaussta.KundenID
  join KDAUSART on KDAUSART.KdAusstaID = KDAUSSTA.id
  join kdarti on kdarti.id = kdausart.KdArtiID
  join artikel on kdarti.ArtikelID = artikel.id
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS [Träger-Nummer], Traeger.Nachname, Traeger.Vorname, Traeger.Titel, Traeger.PersNr AS Personalnummer, Traeger.Indienst AS Indienststellungswoche, Traeger.Ausdienst AS Außerdienststellungswoche, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, TraeArti.Menge AS Sollmenge, ISNULL(Umlaufteile.inBerechnung, 0) AS Umlauf, ausstattung.kdausbez as [Kundenausstattung], ausstattung.menge as [Ausstattungsmenge]
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
LEFT JOIN Umlaufteile ON Umlaufteile.TraeArtiID = TraeArti.ID
JOIN Ausstattung on kdarti.id = ausstattung.kdartiid
WHERE Kunden.ID IN ($1$)
  AND (TraeArti.Menge != 0 OR Umlaufteile.inBerechnung != 0)
  AND Traeger.Status NOT IN (N'K', N'P')
ORDER BY [VSA-Nummer], Nachname, Vorname, [Träger-Nummer];