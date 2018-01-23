SELECT  k.KdNr, TRIM(IIF(k.Name1 IS NULL,'',k.Name1))+' '+TRIM(IIF(k.Name2 IS NULL,'',k.Name2))+' '+TRIM(IIF(k.Name3 IS NULL,'',k.Name3)) AS Kunde, v.VsaNr AS VSANr, TRIM(IIF(v.Name1 IS NULL,'',v.Name1))+' '+TRIM(IIF(v.Name2 IS NULL,'',v.Name2))+' '+TRIM(IIF(v.Name3 IS NULL,'',v.Name3)) AS VSA, (SELECT COUNT(*) FROM Traeger WHERE vsaID=v.ID AND Status='A') AS Anzahl_Traeger, va.ArtikelNr, va.ArtikelBez AS Artikelbezeichnung, COUNT(te.ID) AS Anzahl_Teile
FROM traeger t, vsa v, kunden k, teile te, viewartikel va
WHERE t.vsaID=v.ID
AND v.kundenID=k.ID
AND te.traegerID=t.ID
AND te.artikelID=va.ID
AND t.vsaID in (
	select id 
	from vsa 
	where kundenid in ($1$)
)	
AND te.Status IN ('A', 'E', 'G', 'I', 'K', 'L', 'M', 'O', 'Q', 'S')
AND t.status='A'
GROUP BY KdNr, Kunde, VSANr, VSA, Anzahl_Traeger, ArtikelNr, Artikelbezeichnung
ORDER BY KdNr, VSANr, ArtikelNr