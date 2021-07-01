WITH Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Traeger')
)
SELECT Traeger.PersNr AS Personalnummer, Traeger.Vorname, Traeger.Nachname, Traegerstatus.StatusBez AS [Status Träger], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, TraeArch.Menge, AbtKdArW.EPreis AS Mietpreis, NULL AS Restwert, TraeArch.Menge * AbtKdArW.EPreis AS Nettowert, Wae.IsoCode AS Währung, Wochen.Woche AS Kalenderwoche
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN AbtKdArW ON AbtKdArW.RechPoID = RechPo.ID
JOIN TraeArch ON TraeArch.AbtKdArWID = AbtKdArW.ID
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN Wae ON RechKo.RechWaeID = Wae.ID
WHERE RechKo.ID = $RECHKOID$

UNION

SELECT Traeger.PersNr AS Personalnummer, Traeger.Vorname, Traeger.Nachname, Traegerstatus.StatusBez AS [Status Träger], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, COUNT(Teile.ID) AS Menge, NULL AS Mietpreis, RechPo.EPreis AS Restwert, COUNT(Teile.ID) * RechPo.EPreis AS Nettowert, Wae.IsoCode AS Währung, Teile.Ausdienst AS Kalenderwoche
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Teile ON Teile.RechPoID = RechPo.ID
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Wae ON RechKo.RechWaeID = Wae.ID
WHERE RechKo.ID = $RECHKOID$
GROUP BY Traeger.PersNr, Traeger.Vorname, Traeger.Nachname, Traegerstatus.StatusBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, RechPo.EPreis, Wae.IsoCode, Teile.Ausdienst

ORDER BY Personalnummer, Vorname, Nachname, ArtikelNr, Kalenderwoche;