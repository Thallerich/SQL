WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
)
SELECT Standort.Bez AS Lagerstandort, Lagerort.Lagerort, LagSchr.Bez AS Lagerschrank, Lagerart.LagerartBez$LAN$ AS Lagerart, Lagerart.Zustand, LagerArt.Neuwertig, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez as 'Bereich', ARTGRU.ArtGruBez as 'Artikelgruppe',Artikelstatus.StatusBez AS Artikelstatus, ArtGroe.Groesse, ABC.ABCBez as ABC, BestOrt.Bestand, BestOrt.Reserviert, BestOrt.BestandUrsprung AS [Bestand vom Ursprungsartikel],Bestand.Gleitpreis, Bestand.EntnahmeJahr
, case when Artgroe.id > 0 then artgroe.ekpreis else artikel.ekpreis end as EkPreis
FROM Lagerort
JOIN Standort ON Lagerort.LagerID = Standort.ID
JOIN LagSchr ON Lagerort.LagSchrID = LagSchr.ID
JOIN BestOrt ON BestOrt.LagerortID = Lagerort.ID
JOIN Bestand ON BestOrt.BestandID = Bestand.ID
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN ABC ON ABC.id = Artikel.AbcID
JOIN Artikelstatus ON Artikel.Status = Artikelstatus.Status
JOIN Bereich on Bereich.id = Artikel.BereichID
JOIN ARTGRU on ARTGRU.id = Artikel.ArtGruID
WHERE Standort.ID IN ($1$)
  AND BestOrt.Bestand != 0
  AND (($2$ = 1 AND Lagerart.Neuwertig = 1) OR ($2$ = 0));