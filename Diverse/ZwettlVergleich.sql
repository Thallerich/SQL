SELECT Traeger.Traeger, Traeger.PersNr, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, TraeArti.Menge, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Traemitmenge.Menge AS MengeAlt
FROM Traeger, TraeArti, KdArti, Artikel, ArtGroe, (
  SELECT Traeger.Traeger, Traeger.PersNr, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, TraeArti.Menge, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse
  FROM Traeger, TraeArti, KdArti, Artikel, ArtGroe
  WHERE TraeArti.TraegerID = Traeger.ID
    AND TraeArti.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND TraeArti.ArtGroeID = ArtGroe.ID
    AND Traeger.VsaID = 4242948
    AND TraeArti.Menge > 0
) AS Traemitmenge
WHERE TraeArti.TraegerID = Traeger.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND Traeger.VsaID = 6101549
  AND Traeger.Vorname = Traemitmenge.Vorname
  AND Traeger.Nachname = Traemitmenge.Nachname
  AND Artikel.ArtikelNr = Traemitmenge.ArtikelNr
  AND ArtGroe.Groesse = Traemitmenge.Groesse;