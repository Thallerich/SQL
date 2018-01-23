#Hallo Hr Laure   Wir haben folgendes Problem in Lenzing.   Wir ben�tigen eine m�glichste einfache Advantex Auswertung, bei der wir um ca. 12 Uhr #die Information der bestellten BBK eines Kunden (LKH Salzburg) herausbekommen und nach Enns zur Bestellung weiterleiten k�nnen.   Die Liste m�sste #bei frau Grafinger t�glich generierbar sein und die BBK Artikel je Gr��e und Menge geordnet draufhaben.   Geht das?   Danke! 
#
#21.02.2011 - Bereich w�hlbar, Vsa dazu! Standort nur Lenzing.
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