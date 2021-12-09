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
),
TeileStatus AS ( 
SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT KdGf.KurzBez AS SGF,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kundenstatus.StatusBez AS Kundenstatus,
  Vsa.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  VsaStatus.StatusBez AS [VSA-Status],
  Vsa.Name1,
  Vsa.Name2,
  Vsa.GebaeudeBez,
  Abteil.Abteilung,
  Abteil.Bez as Stammkostenstelle,
  Traeger.Traeger AS TrägerNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.Titel,
  Traegerstatus.StatusBez AS Trägerstatus,
  IIF(Traeger.BerufsgrKdArtiID < 0, NULL, Berufsgruppe.VariantBez) AS Berufsgruppe,
  Traeger.SchrankInfo,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  Teile.Barcode,
  TeileStatus.StatusBez AS [Status Teil],
  Teile.Abmeldung,
  IIF(Teile.AusDienst = N'' OR Teile.AusDienst IS NULL, Teile.RestWertInfo, Teile.AusDRestW) AS Restwert,
  Teile.Alterinfo AS [Alter in Wochen],
  Teile.Indienst,
  Einsatz.EinsatzBez$LAN$ AS [Außerdienststellungs-Grund],
  WegGrund.WegGrundBez$LAN$ AS [Schrott-Grund]
FROM Teile
JOIN Traeger on Teile.TraegerID = Traeger.ID
JOIN ArtGroe on Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel on Teile.ArtikelID = Artikel.ID
JOIN Vsa on Teile.VsaID = Vsa.ID
JOIN Kunden on Vsa.KundenID = Kunden.ID
JOIN KdGf on Kunden.KdGfID = KdGf.ID
JOIN Traegerstatus on Traeger.Status = Traegerstatus.Status
JOIN VsaStatus on  Vsa.Status = VsaStatus.Status
JOIN Kundenstatus on Kunden.Status = Kundenstatus.Status 
JOIN TeileStatus on Teile.Status = Teilestatus.status
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
JOIN KdArti AS Berufsgruppe ON Traeger.BerufsgrKdArtiID = Berufsgruppe.ID
JOIN WegGrund on Teile.WegGrundID = WegGrund.ID
LEFT JOIN Einsatz ON  Teile.AusdienstGrund = Einsatz.EinsatzGrund
WHERE Kunden.ID IN ($4$)
  AND Teile.Status BETWEEN N'U' AND N'W'
  AND Teile.AbmeldDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Teile.Einzug IS NULL
  AND Artikel.BereichID IN ($5$)
ORDER BY SGF, KdNr, VsaNr, Traeger.Nachname, Artikel.ArtikelNr, Größe, [Status Teil];