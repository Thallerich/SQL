select va.ArtikelNr,va.ArtikelBez,va.Packmenge,me.Me,va.BarcodeNr,va.BereichID,va.artgruID
FROM viewartikel va
JOIN ME me ON (va.meID=me.ID)
JOIN kdarti ka ON (ka.ArtikelID=va.ID)
JOIN vsaanf vf ON (vf.kdartiID=ka.ID)
JOIN vsa v on (vf.vsaID=v.ID)
WHERE v.ID=$ID$
AND va.BereichID IN ($1$)

UNION

select va.ArtikelNr,va.ArtikelBez,va.Packmenge,me.Me,va.BarcodeNr,va.BereichID,va.artgruID
FROM viewartikel va
JOIN ME me ON (va.meID=me.ID)
JOIN kdarti ka ON (ka.ArtikelID=va.ID)
WHERE va.ID IN ($2$)
order by va.BereichID,va.artgruID,va.ArtikelNr

-------------------------------------------------------------------------------------------------------

SELECT Vsa.VsaNr AS ArtikelNr, TRIM(IIF(Traeger.Titel IS NULL, '', Traeger.Titel))+' '+TRIM(IIF(Traeger.Vorname IS NULL, '', Traeger.Vorname))+' '+TRIM(IIF(Traeger.Nachname IS NULL, '', Traeger.Nachname)) AS ArtikelBez, /*1*/Schrank.SchrankNr AS Packmenge, /*1*/TraeFach.Fach AS Me, Teile.Barcode AS BarcodeNr, ViewArtikel.BereichID, ViewArtikel.ArtGruID
FROM Teile, ViewArtikel, Traeger, Vsa, TraeFach, Schrank
WHERE Teile.ArtikelID = ViewArtikel.ID
	AND Teile.TraegerID = Traeger.ID
	AND Traeger.VsaID = Vsa.ID
	AND TraeFach.TraegerID = Traeger.ID
	AND TraeFach.SchrankID = Schrank.ID
	AND Teile.VsaID = 35 --605 ohne Schrank  --35 mit Schrank
	AND Teile.Status = 'Q'
	AND ViewArtikel.ArtikelBez <> 'Wäschesack'
	AND Traeger.Nachname <> 'Poolwäsche'
ORDER BY BarcodeNr ASC

--------------------------------------------------------------------------------------------------------

SELECT Traeger.VsaID, COUNT(Traeger.ID) AS Traeger/*, Schrank.SchrankNr*/
FROM Traeger, Vsa, KdBer/*, Schrank*/
WHERE Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = KdBer.KundenID
	/*AND Vsa.ID = Schrank.VsaID*/
	AND KdBer.BereichID = 107
GROUP BY Traeger.VsaID/*, Schrank.SchrankNr*/
