SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, AnfKo.Lieferdatum AS Lieferdatum, FORMAT(OPScans.Zeitpunkt, 'dd.MM.yyyy HH:mm', 'de-AT') AS Einlesezeitpunkt, AnfKo.AuftragsNr AS Packzettel, AnfKo.DruckZeitpunkt AS PZDruckzeitpunkt, LsKo.LsNr, LsKo.DruckZeitpunkt AS LSDruckzeitpunkt, COUNT(OPScans.ID) AS Eingang, AnfPo.Angefordert, AnfPo.Geliefert AS Ausgang, AnfPo.Geliefert - AnfPo.Angefordert AS Differenz
FROM AnfPo, AnfKo, Vsa, Kunden, KdArti, Artikel, OPScans, LsKo
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND OPScans.EingAnfPoID = AnfPo.ID
  AND Kunden.ID = $ID$
  AND AnfKo.Lieferdatum BETWEEN $1$ AND $2$
  AND Vsa.Status = 'A'
  AND AnfKo.LsKoID = LsKo.ID
GROUP BY Kunden.Kdnr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, AnfKo.Lieferdatum, FORMAT(OPScans.Zeitpunkt, 'dd.MM.yyyy HH:mm', 'de-AT'), AnfKo.AuftragsNr, AnfKo.DruckZeitpunkt, LsKo.LsNr, LsKo.DruckZeitpunkt, AnfPo.Angefordert, AnfPo.Geliefert

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, AnfKo.Lieferdatum AS Lieferdatum, FORMAT(OPScans.Zeitpunkt, 'dd.MM.yyyy HH:mm', 'de-AT') AS Einlesezeitpunkt, AnfKo.AuftragsNr AS Packzettel, AnfKo.DruckZeitpunkt AS PZDruckzeitpunkt, LsKo.LsNr, LsKo.DruckZeitpunkt AS LSDruckzeitpunkt, COUNT(OPScans.ID) AS Eingang, AnfPo.Angefordert, AnfPo.Geliefert AS Ausgang, AnfPo.Geliefert - AnfPo.Angefordert AS Differenz
FROM AnfPo, AnfKo, Vsa, Kunden, KdArti, Artikel, Salesianer_Archive.dbo.OPScans, LsKo
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND OPScans.EingAnfPoID = AnfPo.ID
  AND Kunden.ID = $ID$
  AND AnfKo.Lieferdatum BETWEEN $1$ AND $2$
  AND Vsa.Status = 'A'
  AND AnfKo.LsKoID = LsKo.ID
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, AnfKo.LieferDatum, FORMAT(OPScans.Zeitpunkt, 'dd.MM.yyyy HH:mm', 'de-AT'), AnfKo.AuftragsNr, AnfKo.DruckZeitpunkt, LsKo.LsNr, LsKo.DruckZeitpunkt, AnfPo.Angefordert, AnfPo.Geliefert

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKo.Datum AS Lieferdatum, CONVERT(nvarchar, NULL) AS Einlesezeitpunkt, '' AS Packzettel, CONVERT(date, NULL) AS PZDruckzeitpunkt, LsKo.LsNr, LsKo.DruckZeitpunkt AS LSDruckzeitpunkt, 0 AS Eingang, 0 AS Angefordert, LsPo.Menge AS Ausgang, LsPo.Menge * -1 AS Differenz
FROM LsPo, LsKo, Vsa, Kunden, KdArti, Artikel
WHERE LsPo.LsKoID = LsKo.ID
  AND LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.ID = $ID$
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND Vsa.Status = 'A'
  AND NOT EXISTS (SELECT AnfKo.* FROM AnfKo WHERE AnfKo.LsKoID = LsKo.ID)
ORDER BY Kunden.KdNr, VsaNr, Artikel.ArtikelNr, LieferDatum;