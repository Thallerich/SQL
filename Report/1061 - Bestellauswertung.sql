SELECT Lagerart.Lagerart, Lagerart.LagerartBez$LAN$ AS Lagerartbezeichnung, Lief.LiefNr AS LieferantNr, Lief.SuchCode AS [Lieferanten-Stichwort], BKo.BestNr AS [Bestellung Nr.], BKo.Datum AS Bestelldatum, Bestellstatus.StatusBez AS [Status der Bestellung], BKoArt.BKoArtBez$LAN$ AS [Art der Bestellung], BPo.Pos AS Positionsnummer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, BPo.Menge AS [bestellte Menge], BPo.LiefMenge AS [bereits geliefert], IIF(BPo.LiefMenge > BPo.Menge, 0, BPo.Menge - BPo.LiefMenge) AS [noch offen], LiefAbKo.ABNr, LiefAbKo.Datum AS [AB-Datum], LiefAbPo.Menge AS [bestätigte Menge], LiefAbPo.Termin AS [Liefertermin lt. AB], BKo.ID AS BKoID
FROM BPo
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
LEFT JOIN LiefAbKo ON BPo.LatestLiefABKoID = LiefAbKo.ID
LEFT JOIN LiefAbPo ON LiefAbPo.LiefABKoID = LiefAbKo.ID AND LiefAbPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN BKoArt ON BKo.BKoArtID = BKoArt.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'BKO'
) AS Bestellstatus ON BKo.[Status] = Bestellstatus.[Status]
JOIN Lagerart ON BKo.LagerArtID = Lagerart.ID
WHERE BKo.LagerID IN ($1$)
  AND Bestellstatus.ID IN ($2$)
  AND Lief.ID IN ($3$)
  AND (($4$ = 0 AND BKo.BKoArtID != 16) OR ($4$ = 1))  /* Kontrakte ausblenden wenn gewünscht */
ORDER BY Lagerart, [Bestellung Nr.], Positionsnummer;