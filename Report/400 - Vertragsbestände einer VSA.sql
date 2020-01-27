WITH VsaAnfStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'VSAANF')
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, VsaAnfStatus.StatusBez AS [Status anforderbarer Artikel], VsaAnf.Bestand AS Vertragsbestand, VsaAnf.BestandIst AS [Ist-Bestand]
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN VsaAnfStatus ON VsaAnf.Status = VsaAnfStatus.Status
WHERE (($1$ = 1 AND VsaAnf.Bestand != 0) OR ($1$ = 0))
  AND Vsa.ID = $ID$
  AND VsaAnf.Status != N'I'
  AND Vsa.Status = N'A'
ORDER BY Kunden.KdNr, [Vsa-Stichwort], Artikel.ArtikelNr;