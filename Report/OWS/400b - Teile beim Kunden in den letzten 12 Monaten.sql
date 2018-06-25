WITH LastLS (OPTeileID, OPScansID) AS (

  SELECT OPScans.OPTeileID, MAX(OPScans.ID) AS OPScansID
  FROM OPScans
  GROUP BY OPScans.OPTeileID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, LsKo.LsNr, LsKo.Datum AS Lieferdatum, LsPo.Menge AS Liefermenge, LsPo.Menge - COUNT(OPScans.OPTeileID) AS Retour, COUNT(OPScans.OPTeileID) AS [noch beim Kunden], AnfKo.Sonderfahrt AS Sonderlieferung, CAST(IIF(AnfPo.Memo = N'Bestands-Auslieferung', 1, 0) AS bit) AS [Auslieferung Bestandsveränderung]
FROM LsPo, LsKo, Vsa, Kunden, KdArti, Artikel, AnfKo, AnfPo, OPScans, LastLS
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND AnfKo.LsKoID = LsKo.ID
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfPo.KdArtiID = LsPo.KdArtiID
  AND OPScans.AnfPoID = AnfPo.ID
  AND OPScans.ID = LastLS.OPScansID
  AND DATEDIFF(month, LsKo.Datum, CAST(GETDATE() AS date)) <= 12
  AND OPScans.AnfPoID > 0
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, LsKo.LsNr, LsKo.Datum, LsPo.Menge, AnfKo.Sonderfahrt, CAST(IIF(AnfPo.Memo = N'Bestands-Auslieferung', 1, 0) AS bit)
ORDER BY Kunden.KdNr, Vsa.VsaNr, Artikel.ArtikelNr, Lieferdatum;