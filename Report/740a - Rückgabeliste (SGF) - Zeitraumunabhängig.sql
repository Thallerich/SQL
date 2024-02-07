DECLARE @curweek nchar(7) = (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat);

WITH Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
),
VsaStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VSA'
),
Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
),
TeileSTatus as ( 
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS Kundenstatus, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], VsaStatus.StatusBez AS [VSA-Status], VSA.Name1, VSA.Name2, Vsa.GebaeudeBez AS Gebäude, Abteil.Abteilung AS [Stamm-Kostenstelle], Abteil.Bez AS [Stamm-Kostenstellenbezeichnung], Traeger.Traeger AS [Träger-Nr], Traeger.PersNr AS Personalnummer, Traeger.Nachname, Traeger.Vorname, Traeger.Titel, Traegerstatus.StatusBez AS Trägerstatus, IIF(Traeger.BerufsgrKdArtiID < 0, NULL, Berufsgruppe.VariantBez) AS Berufsgruppe, Traeger.SchrankInfo, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Barcode, TeileStatus.StatusBez AS [Status Teil], EinzHist.Abmeldung, RestwertAktuell.RestwertInfo AS Restwert, RestwertAktuell.Alterinfo AS [Alter in Wochen], Standort.Suchcode AS Expedition, EinzHist.Indienst, Einsatz.EinsatzBez$LAN$ AS Ausdienstgrund, Weggrund.WeggrundBez$LAN$ AS Schrottgrund, KdArti.ID AS KdArtiID
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
CROSS APPLY funcGetRestwert(EinzHist.ID, @curweek, 1) AS RestwertAktuell
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Traegerstatus ON Traeger.Status = Traegerstatus.Status
JOIN VsaStatus ON  Vsa.Status = VsaStatus.Status
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status 
JOIN TeileStatus ON EinzHist.Status = Teilestatus.status
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
JOIN KdArti AS Berufsgruppe ON Traeger.BerufsgrKdArtiID = Berufsgruppe.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Standort ON StandBer.ExpeditionID = Standort.ID
JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
JOIN Einsatz ON EinzHist.Ausdienstgrund = Einsatz.Einsatzgrund
WHERE Kunden.ID IN ($3$)
  AND KdBer.BereichID IN ($4$)
  AND Standort.ID IN ($5$)
  AND Kunden.StandortID IN ($6$)
  AND EinzHist.Status = N'W'
  AND EinzHist.Einzug IS NULL
  AND EinzHist.PoolFkt = 0
ORDER BY Geschäftsbereich, KdNr, VsaNr, Traeger.Nachname, Artikel.ArtikelNr, Größe, [Status Teil];