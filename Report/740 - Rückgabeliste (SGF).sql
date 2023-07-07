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
  WHERE [Status].Tabelle = UPPER(N'EINZHIST')
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
  EinzHist.Barcode,
  TeileStatus.StatusBez AS [Status Teil],
  EinzHist.Abmeldung,
  IIF(EinzHist.AusDienst = N'' OR EinzHist.AusDienst IS NULL, EinzHist.RestWertInfo, EinzHist.AusDRestW) AS Restwert,
  EinzTeil.Alterinfo AS [Alter in Wochen],
  EinzHist.Indienst,
  Einsatz.EinsatzBez$LAN$ AS [Außerdienststellungs-Grund],
  WegGrund.WegGrundBez$LAN$ AS [Schrott-Grund]
FROM EinzHist
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN Traeger on EinzHist.TraegerID = Traeger.ID
JOIN ArtGroe on EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel on EinzHist.ArtikelID = Artikel.ID
JOIN Vsa on EinzHist.VsaID = Vsa.ID
JOIN Kunden on Vsa.KundenID = Kunden.ID
JOIN KdGf on Kunden.KdGfID = KdGf.ID
JOIN Traegerstatus on Traeger.Status = Traegerstatus.Status
JOIN VsaStatus on  Vsa.Status = VsaStatus.Status
JOIN Kundenstatus on Kunden.Status = Kundenstatus.Status 
JOIN TeileStatus on EinzHist.Status = Teilestatus.status
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
JOIN KdArti AS Berufsgruppe ON Traeger.BerufsgrKdArtiID = Berufsgruppe.ID
JOIN WegGrund on EinzHist.WegGrundID = WegGrund.ID
LEFT JOIN Einsatz ON  EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
WHERE Kunden.ID IN ($4$)
  AND EinzHist.Status BETWEEN N'U' AND N'W'
  AND EinzHist.AbmeldDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND EinzHist.Einzug IS NULL
  AND EinzHist.IsCurrEinzHist = 1
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
  AND (EinzTeil.AltenheimModus = 0 OR Artikel.ArtGruID IN (SELECT ArtGru.ID FROM ArtGru WHERE ArtGru.Sack = 1))
  AND Artikel.BereichID IN ($5$)
ORDER BY SGF, KdNr, VsaNr, Traeger.Nachname, Artikel.ArtikelNr, Größe, [Status Teil];