WITH Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
),
Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Traeger.Traeger AS TrägerNr, Traeger.PersNr, Traegerstatus.StatusBez AS [Status Träger], Traeger.Nachname, Traeger.Vorname, Traeger.SchrankInfo AS [Schrank/Fach], EinzHist.Barcode, Teilestatus.StatusBez AS [Status Teil], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Indienst AS IndienstWoche, EinzHist.Ausgang1, EinzHist.Eingang1, BerufsgrpArti.VariantBez AS Berufsgruppe, Traeger.VormalsNr AS [Sonstige Daten], Kunden.Name1 AS Kunde, Vsa.Bez + ' (' + Vsa.SuchCode + ')' AS VSA, Abteil.Bez AS Kostenstelle
FROM EinzTeil, EinzHist, TraeArti, Traeger, Vsa, Kunden, KdArti, Artikel, Abteil, ArtGroe, KdArti AS BerufsgrpArti, Traegerstatus, Teilestatus
WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
  AND EinzHist.TraeArtiID = TraeArti.ID
  AND TraeArti.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Traeger.AbteilID = Abteil.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND Traeger.BerufsgrKdArtiID = BerufsgrpArti.ID
  AND Traeger.Status = Traegerstatus.Status
  AND EinzHist.Status = Teilestatus.Status
  AND Kunden.ID = $ID$
  AND EinzHist.Indienst <= $1$
  AND (EinzHist.Ausdienst > $1$ OR EinzHist.Ausdienst IS NULL)
  AND EinzHist.Kostenlos = 0
  AND EinzHist.PoolFkt = 0
  AND EinzHist.EinzHistTyp = 1
ORDER BY Kunden.Kdnr, VSA, Traeger.Nachname, Traeger.Vorname;