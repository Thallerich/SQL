DECLARE @von date = $1$;
DECLARE @bis date = $2$;

WITH OPSchrott AS (
  SELECT OPTeile.ArtikelID, StandBer.ProduktionID, COUNT(OPTeile.ID) AS SchrottMenge
  FROM OPTeile
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Artikel.BereichID
  WHERE OPTeile.WegDatum BETWEEN @von AND @bis
    AND StandBer.ProduktionID IN ($3$)
    AND OPTeile.Status = N'Z'
  GROUP BY OPTeile.ArtikelID, StandBer.ProduktionID
)
SELECT Standort.Bez AS Produktion, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe, SUM(CAST(LsPo.Menge AS int) * (OPSets.Menge / OPSetArtikel.Packmenge)) AS Liefermenge, OPSchrott.SchrottMenge AS Schrottmenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN OPSets ON OPSets.ArtikelID = KdArti.ArtikelID
JOIN Artikel ON OPSets.Artikel1ID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Standort ON LsPo.ProduktionID = Standort.ID
JOIN Artikel AS OPSetArtikel ON OPSets.ArtikelID = OPSetArtikel.ID
LEFT OUTER JOIN OPSchrott ON OPSchrott.ArtikelID = Artikel.ID AND OPSchrott.ProduktionID = Standort.ID
WHERE LsKo.Datum BETWEEN @von AND @bis
  AND LsPo.ProduktionID IN ($3$)
GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGru.ArtGruBez$LAN$, OPSchrott.SchrottMenge;