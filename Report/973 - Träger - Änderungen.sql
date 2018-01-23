SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, TraeArti.Menge, MassOrt.MassOrtBez$LAN$ AS Änderungsart, TraeMass.Mass AS [Maß], MassOrt.AufBKoDrucken AS [Bei Sonderanfertigung auf Bestellung drucken], MassOrt.DurchLief AS [Immer auf Bestellung drucken], MassOrt.ImmerBestellen AS [Immer direkt bestellen], MassOrt.CopyGroeTausch AS [bei Größentausch kopieren], IIF(ArtGroe.Gesamtlaenge = 0, NULL, ArtGroe.Gesamtlaenge) AS [Standard-Gesamtlänge], IIF(ArtGroe.Schrittlaenge = 0, NULL, ArtGroe.Schrittlaenge) AS [Standard-Schrittlänge], IIF(ArtGroe.Armlaenge = 0, NULL, ArtGroe.Armlaenge) AS [Standard-Armlänge], IIF(ArtGroe.Beinlaenge = 0, NULL, ArtGroe.Beinlaenge) AS [Standard-Beinlänge]
FROM TraeMass, MassOrt, TraeArti, Traeger, Vsa, Kunden, KdGf, KdArti, Artikel, ArtGroe
WHERE TraeMass.MassOrtID = MassOrt.ID
  AND TraeMass.TraeArtiID = TraeArti.ID
  AND TraeArti.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND Traeger.Status = 'A'
  AND TraeArti.Menge > 0
  AND KdGf.ID IN ($1$)
ORDER BY SGF, KdNr, Traeger, ArtikelNr;