WITH Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TRAEGER')
),
VsaStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'VSA')
),
Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
)
SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS Kundenstatus, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], VsaStatus.StatusBez AS [VSA-Status], Traeger.Nachname, Traeger.Vorname, Traeger.Titel, Traegerstatus.StatusBez AS Trägerstatus, IIF(Traeger.BerufsgrKdArtiID < 0, NULL, Berufsgruppe.VariantBez) AS Berufsgruppe, Traeger.SchrankInfo, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Teile.Barcode, Teile.Abmeldung, IIF(Teile.AusDienst='' OR Teile.AusDienst IS NULL, Teile.RestWertInfo, Teile.AusDRestW) AS Restwert
FROM Teile, Traeger, ArtGroe, Artikel, Vsa, Kunden, KdGf, Traegerstatus, VsaStatus, Kundenstatus, KdArti AS Berufsgruppe
WHERE Teile.TraegerID = Traeger.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Traeger.Status = Traegerstatus.Status
  AND Vsa.Status = VsaStatus.Status
  AND Kunden.Status = Kundenstatus.Status
  AND Traeger.BerufsgrKdArtiID = Berufsgruppe.ID
  AND KdGf.ID IN ($1$)  -- Geschäftsfeld
  AND Kunden.ID IN ($2$) -- Kunden abhängig von Geschäftsfeld
  AND Teile.Status = 'W'  -- Rückgabe-Teile
  AND Teile.AbmeldDat BETWEEN $4$ AND $5$ -- Datum der Abmeldung
  AND Teile.Einzug IS NULL -- noch nicht in Produktion eingelesen
  AND Artikel.BereichID IN ($3$)
ORDER BY SGF, KdNr, VsaNr, Traeger.Nachname, Artikel.ArtikelNr, Größe;