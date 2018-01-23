SELECT Traeger.Traeger, Traeger.Titel, Traeger.Nachname, Traeger.Vorname, Traeger.Status, Status.Bez AS Statusbezeichnung, Traeger.KostenlosVon, Traeger.KostenlosBis, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, TraeArti.Menge
FROM TraeArti, Traeger, Vsa, Kunden, KdArti, Artikel, ArtGroe, (
  SELECT Status.Status, Status.StatusBez$LAN$ AS Bez
  FROM Status
  WHERE Status.Tabelle = 'TRAEGER'
) AS Status
WHERE TraeArti.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Traeger.Status = Status.Status
  AND TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND Kunden.ID = $KUNDENID$
  AND Traeger.Status IN ('P', 'K')
  AND TraeArti.Menge > 0
ORDER BY Traeger.Status, Traeger.Traeger;