WITH Liefermenge AS (
  SELECT LsPo.KdArtiID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  GROUP BY LsPo.KdArtiID
  HAVING SUM(LsPo.Menge) != 0
)
SELECT KdArti.ID AS KdArtiID, Standort.SuchCode AS Haupstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.BereichBez$LAN$ AS Kundenbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, KdArti.WaschPreis AS Bearbeitung, KdArti.LeasPreis AS Leasing, KdArti.Umlauf, KdArti.AbrechMenge AS Abrechnungsmenge, Liefermenge.Liefermenge
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
LEFT JOIN Liefermenge ON Liefermenge.KdArtiID = KdArti.ID
WHERE (KdArti.Umlauf != 0 OR Liefermenge.Liefermenge IS NOT NULL)
  AND (($2$ = 1 AND (KdArti.AbrechMenge * KdArti.LeasPreis != 0 OR KdArti.WaschPreis * ISNULL(Liefermenge.Liefermenge, 0) != 0)) OR ($2$ = 0))
  AND KdArti.Status = N'I'
  AND Kunden.FirmaID = $1$
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);