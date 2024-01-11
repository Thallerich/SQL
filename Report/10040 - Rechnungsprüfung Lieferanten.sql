WITH LiefRKoStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'LIEFRKO'
)
SELECT Lief.LiefNr AS [Lieferant-Nr.], Lief.Name1 AS Lieferant, LiefLsKo.LsNr AS [Lieferanten-Lieferschein], LiefLsKo.WeDatum AS [Wareneingangs-Datum], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, LiefLsPo.Menge AS Liefermenge, BPo.Menge AS [Bestellte Menge], LiefRKo.RechNr AS [Rechnungsnummer Lierferant], LiefRKo.Datum AS Rechnungsdatum, LiefRKoStatus.StatusBez AS [Status der Rechnung]
FROM LiefLsPo
JOIN LiefLsKo ON LiefLsPo.LiefLsKoID = LiefLsKo.ID
JOIN Lief ON LiefLsKo.LiefID = Lief.ID
JOIN BPo ON LiefLsPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Lagerart ON BKo.LagerArtID = Lagerart.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
LEFT JOIN LiefRPo ON LiefLsPo.ID = LiefRPo.LiefLsPoID
LEFT JOIN LiefRKo ON LiefRPo.LiefRKoID = LiefRKo.ID
LEFT JOIN LiefRKoStatus ON LiefRKo.[Status] = LiefRKoStatus.[Status]
WHERE LiefLsKo.WeDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Lagerart.FirmaID = $1$
  AND (($2$ = 1 AND LiefRPo.ID IS NULL) OR ($2$ = 0 AND (LiefRKo.Status < N'N' OR LiefRPo.ID IS NULL)))
  AND LiefLsPo.Menge != 0
  AND LiefLsKo.[Status] < N'S';