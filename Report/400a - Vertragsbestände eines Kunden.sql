WITH AnfArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VSAANF'
),
LiefertageWoche AS (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, COUNT(DISTINCT Touren.Wochentag) AS AnzahlLT
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  WHERE CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
  GROUP BY VsaTour.VsaID, VsaTour.KdBerID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, AnfArtiStatus.StatusBez AS [Status anforderbarer Artikel], VsaAnf.Bestand AS Vertragsbestand, VsaAnf.BestandIst AS [Ist-Bestand], VsaAnf.MaxBestellMenge AS [maximale Bestellmenge], LiefertageWoche.AnzahlLT AS [Anzahl Liefertage pro Woche], Betreuer.Name AS Kundenbetreuer, AnfArt.AnfArtBez$LAN$ AS Anforderungsart
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN VsaBer ON KdArti.KdBerID = VsaBer.KdBerID AND Vsa.ID = VsaBer.VsaID
JOIN Mitarbei AS Betreuer ON VsaBer.BetreuerID = Betreuer.ID
JOIN AnfArt ON Vsa.AnfArtID = AnfArt.ID
JOIN AnfArtiStatus ON VsaAnf.[Status] = AnfArtiStatus.[Status]
JOIN LiefertageWoche ON Vsa.ID = LiefertageWoche.VsaID AND VsaBer.KdBerID = LiefertageWoche.KdBerID
WHERE Kunden.ID IN ($3$)
  AND Betreuer.ID IN ($4$)
  AND (($5$ = 0) OR ($5$ = 1 AND VsaAnf.Bestand != 0))
  AND VsaAnf.Status != N'I'
  AND Vsa.[Status] = N'A'
  AND Kunden.[Status] = N'A'
  AND Vsa.SichtbarID IN ($SICHTBARIDS$);