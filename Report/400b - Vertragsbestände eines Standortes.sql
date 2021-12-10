WITH VsaAnfStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'VSAANF')
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Bereich.Bereich AS Kundenbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, VsaAnfStatus.StatusBez AS [Status anforderbarer Artikel], VsaAnf.Bestand AS Vertragsbestand, VsaAnf.BestandIst AS [Ist-Bestand]
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID 
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID 
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN VsaAnfStatus ON VsaAnf.Status = VsaAnfStatus.Status
WHERE (($2$ = 1 AND VsaAnf.Bestand != 0) OR ($2$ = 0))
  AND VsaAnf.Status != N'I'
  AND Vsa.Status = N'A'
  AND Kunden.StandortID IN ($1$)
  AND Bereich.ID IN ($3$)
ORDER BY Kunden.KdNr, [Vsa-Stichwort], Artikel.ArtikelNr;