-- Ticket# 16272: Auswertung OP-Teile
-- OP-Teile, die sich in den letzten 6 Monaten gedreht haben + EK

OpTeile -> OpScans
OpTeile -> ViewArtikel

SELECT OpTeile.Code, Status.Bez AS Status, OpTeile.ErstWoche, OpTeile.AnzWasch, ViewArtikel.EKPreis, ViewArtikel.ArtikelNr, ViewArtikel.BestNr, ViewArtikel.ArtikelBez, MAX(OpScans.Zeitpunkt) AS LetzterEingang
FROM OpTeile, OpScans, ZielNr, ViewArtikel, Status
WHERE OpTeile.ArtikelID = ViewArtikel.ID
	AND OpScans.OpTeileID = OpTeile.ID
	AND OpScans.ZielNrID = ZielNr.ID
	AND OpTeile.Status = Status.Status
	AND Status.Tabelle = 'OPTEILE'
	AND ViewArtikel.LanguageID = $LANGUAGE$
	AND ZielNr.ID = 10000001
	AND TIMESTAMPDIFF(SQL_TSI_MONTH, OpScans.Zeitpunkt, CURDATE()) <= 6
GROUP BY OpTeile.Code, Status, OpTeile.ErstWoche, OpTeile.AnzWasch, ViewArtikel.EKPReis, ViewArtikel.ArtikelNr, ViewArtikel.BestNr, ViewArtikel.ArtikelBez