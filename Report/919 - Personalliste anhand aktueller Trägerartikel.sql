SELECT Kunden.ID AS KundenID,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS VsaStichwort,
  Vsa.Bez AS VsaBez,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Traeger.ID AS TraegerID,
  Traeger.Traeger,
  Traeger.PersNr,
  Traeger.Titel,
  Traeger.Nachname,
  Traeger.Vorname,
  Schrank = (
    SELECT TOP 1 Schrank.SchrankNr 
    FROM TraeFach
    JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
    WHERE TraeFach.TraegerID = Traeger.ID
  ),
  Fach = (
    SELECT TOP 1 TraeFach.Fach
    FROM TraeFach
    WHERE TraeFach.TraegerID = Traeger.ID
  ),
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS ArtikelBez,
  ArtGroe.Groesse,
  TraeArti.Menge
FROM TraeArti, KdArti, Artikel, ArtGroe, Traeger, Vsa, Kunden, Abteil
WHERE TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND TraeArti.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Traeger.AbteilID = Abteil.ID
  AND Kunden.ID = $ID$
  AND Traeger.Status IN ('A', 'K')
  AND ((Vsa.RentomatID < 0 AND TraeArti.Menge > 0) OR (Vsa.RentomatID > 0 AND Traeger.RentoArtID <> 3))
ORDER BY Kunden.KdNr, Vsa.VsaNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr;