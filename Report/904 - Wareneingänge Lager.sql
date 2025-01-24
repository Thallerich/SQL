SELECT Lief.LiefNr, Lief.Name1 AS Lieferant, LiefLsKo.WeDatum AS [Datum Wareneingang], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, SUM(LiefLsPo.Menge) AS Menge, BPo.Einzelpreis, Lief.WaeID AS Einzelpreis_WaeID, Standort.Bez AS Lager, Lagerart.LagerartBez$LAN$ AS Lagerart
FROM LiefLsPo
JOIN LiefLsKo ON LiefLsPo.LiefLsKoID = LiefLsKo.ID
JOIN Lief ON LiefLsKo.LiefID = Lief.ID
JOIN BPo ON LiefLsPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Lagerart ON BKo.LagerArtID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE LiefLsKo.WeDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Standort.ID IN ($2$)
GROUP BY Lief.LiefNr, Lief.Name1, LiefLsKo.WeDatum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, BPo.Einzelpreis, Lief.WaeID, Standort.Bez, Lagerart.LagerartBez$LAN$
HAVING SUM(LiefLsPo.Menge) != 0;