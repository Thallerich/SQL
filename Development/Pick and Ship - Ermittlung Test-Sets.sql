USE Salesianer_Test
GO

DECLARE @OPAblauf int = (SELECT CAST(ValueMemo AS int) FROM Settings WHERE Parameter = N'OP_ZU_PACKZETTEL_VOR_ABLAUF');

SELECT TOP 10 Kunden.KdNr, Vsa.VsaNr, Vsa.Bez, OPEtiKo.EtiNr, OPEtiKo.[Status], OPEtiKo.VerfallDatum, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGru.Gruppe, ArtGru.Steril
FROM OPEtiKo
JOIN Vsa ON OPEtiKo.PackVsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE OPEtiKo.[Status] = N'M'
  AND DATEADD(day, @OPAblauf * -1, OPEtiKo.VerfallDatum) > CAST(GETDATE() AS date)
  AND OPEtiKo.PackVsaID > 0;