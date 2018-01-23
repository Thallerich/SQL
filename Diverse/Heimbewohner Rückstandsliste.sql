SELECT MAX(Scans.DateTime) AS "Letzter Scan", (
	SELECT TOP 1 ZielNr.Bez
		FROM ZielNr, Scans
		WHERE Scans.ZielNrID = ZielNr.ID
			AND Scans.TeileID = a.ID
		ORDER BY Scans.DateTime DESC
	) AS "Letztes Ziel", a.*
FROM (
	SELECT Teile.ID AS ID, Kunden.KdNr, Kunden.Name2, Kunden.Name3, Kunden.Name1 AS Kunde, Teile.Barcode AS Seriennummer, Artikel.ArtikelBez AS Artikel, Teile.Status, Teile.Eingang1, Teile.Ausgang1, IFNULL(TRIM(Traeger.Nachname), '') + ' ' + IFNULL(TRIM(Traeger.Vorname), '') AS Träger, Traeger.PersNr AS ZimmerNr, VSA.SuchCode, VSA.Bez AS Bez, VSA.Name1 AS Vsa, VSA.Name2 AS VSA2, VSA.Name3 AS VSA3
	FROM Teile, Traeger, VSA, Kunden, ViewArtikel Artikel, Prod
	WHERE Teile.TraegerID = Traeger.ID
        AND Prod.TeileID = Teile.ID	
		AND Traeger.VSAID = VSA.ID
		AND VSA.KundenID = Kunden.ID
		AND Kunden.ID = $1$
		AND Teile.Eingang1 >= '2008-09-15'
		AND (Teile.Eingang1 > Teile.Ausgang1 OR Teile.Ausgang1 IS NULL)
		AND Teile.Status IN ('Q', 'M')
		AND Teile.ArtikelID = Artikel.ID
		AND Artikel.BereichID = 107
		AND Prod.AusDat >= CURDATE()
	) a, Scans
WHERE a.ID = Scans.TeileID
GROUP BY 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
HAVING CONVERT(MAX(DateTime), SQL_DATE) <= $2$
ORDER BY SuchCode, Träger;


---------------------------------------------------- vvv HBWL Neu vvv ----------------------------------------------------------------------------
SELECT Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Teile.Barcode, ViewArtikel.ArtikelBez, Teile.Eingang1 AS Eingang, Teile.Ausgang1, Traeger.Nachname, Traeger.Vorname, Traeger.PersNr AS Zimmer, Vsa.SuchCode, Vsa.Bez, Vsa.Name2, Vsa.Name3
FROM Vsa, Kunden, Teile, ViewArtikel, Traeger
WHERE Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Teile.ArtikelID = ViewArtikel.ID
	AND Teile.TraegerID = Traeger.ID
	AND Kunden.KdNr = 5014
	AND ViewArtikel.BereichID = 107
	AND Teile.Status IN ('Q', 'M')
	AND Teile.Eingang1 IS NOT NULL
	AND (Teile.Eingang1 > Teile.Ausgang1 OR Teile.Ausgang1 IS NULL)
ORDER BY Kunden.KdNr, Vsa.SuchCode, Zimmer