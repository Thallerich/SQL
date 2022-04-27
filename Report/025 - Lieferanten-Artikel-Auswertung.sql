SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Standort.SuchCode AS Lagerstandort, Lief.LiefNr, Lief.Name1 AS Lieferant, ArGrLief.BestellNr, ArGrLief.BestellInfoText, ArGrLief.EkPreis, Wae.IsoCode AS Währung, LiefTage.LiefTageBez AS Liefertage, ArtGroe.ID AS ArtGroeID
FROM ArGrLief
JOIN ArtGroe ON ArGrLief.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
JOIN ArtiLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
JOIN Lief ON ArtiLief.LiefID = Lief.ID
JOIN Wae ON Lief.WaeID = Wae.ID
JOIN LiefTage ON ArGrLief.LiefTageID = LiefTage.ID
JOIN Standort ON ArtiLief.StandortID = Standort.ID
WHERE (($2$ != N'' AND Artikel.ArtikelNr LIKE REPLACE($2$, N'*', N'%')) OR $2$ = N'')
  AND (($3$ != N'' AND CAST(Lief.LiefNr AS nvarchar) LIKE REPLACE($3$, N'*', N'%')) OR $3$ = N'')
  AND (($4$ != N'' AND ArGrLief.BestellNr LIKE REPLACE($4$, N'*', N'%')) OR $4$ = N'')
  AND Standort.ID IN ($1$)
ORDER BY ArtikelNr, LiefNr, GroePo.Folge;