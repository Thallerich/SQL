#Hallo Hr Laure   Wir haben folgendes Problem in Lenzing.   Wir benötigen eine möglichste einfache Advantex Auswertung, bei der wir um ca. 12 Uhr #die Information der bestellten BBK eines Kunden (LKH Salzburg) herausbekommen und nach Enns zur Bestellung weiterleiten können.   Die Liste müsste #bei frau Grafinger täglich generierbar sein und die BBK Artikel je Größe und Menge geordnet draufhaben.   Geht das?   Danke! 
#
#21.02.2011 - Bereich wählbar, Vsa dazu! Standort nur Lenzing.
#
#03.03.2011 - Kunde, Vsa weg, nur noch eine Summe je Artikel. Mehrfachauswahl von Kunden funktioniert scheinbar nicht.
#
#################################################################################################################################################

SELECT ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, SUM(AnfPo.Angefordert) AS Angefordert, Bereich.Bereich, Bereich.Bez
FROM AnfKo, AnfPo, Vsa, Kunden, KdArti, ViewArtikel, KdBer, Bereich, Touren, Standort
WHERE AnfKo.ID = AnfPo.AnfKoID
	AND AnfKo.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND AnfPo.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = ViewArtikel.ID
	AND KdArti.KdBerID = KdBer.ID
	AND KdBer.BereichID = Bereich.ID
	AND AnfKo.TourenID = Touren.ID
	AND Touren.ExpeditionID = Standort.ID
	AND Kunden.ID IN ($1$)
	AND AnfKo.AuftragsDatum = $2$
	AND Bereich.ID IN ($3$)
	AND AnfPo.Angefordert > 0
	AND Standort.ID IN ($4$)
GROUP BY ArtikelNr, ArtikelBez, Bereich, Bereich.Bez
ORDER BY ArtikelNr ASC 