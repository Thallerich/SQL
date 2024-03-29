SELECT Kunden.KdNr, Kunden.ID AS KundenID, Vsa.Bez AS VsaBez, Abteil.Bez AS KsSt, Traeger.ID AS TraegerID, Traeger.PersNr, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, Traeger.SchrankInfo, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse, Teile.Indienst, Teile.Ausdienst, Teile.Ausgang1, Teile.Eingang1, GETDATE() - IIF(Teile.Eingang1 <= Teile.Ausgang1, Teile.Ausgang1, Teile.Eingang1) AS Tage, Teile.Kostenlos, Teile.RuecklaufK
FROM Teile, Traeger, Vsa, Kunden, Artikel, ArtGroe, Abteil
WHERE Teile.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND Traeger.AbteilID = Abteil.ID
  AND Kunden.ID = $KUNDENID$
  AND Teile.Indienst IS NOT NULL
  AND Traeger.Status IN ('A', 'K')
  AND Teile.Status IN ('Q', 'S')
ORDER BY VsaBez, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr;