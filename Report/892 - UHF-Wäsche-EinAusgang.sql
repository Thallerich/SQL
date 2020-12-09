WITH Eingangsscans AS (
  SELECT OPScans.ID, OPScans.EingAnfPoID, OPScans.Zeitpunkt
  FROM OPScans
  WHERE OPScans.EingAnfPoID > 0
),
Eingangsscans_Archiv AS (
  SELECT OPScans.ID, OPScans.EingAnfPoID, OPScans.Zeitpunkt
  FROM Salesianer_Archive.dbo.OPScans
  WHERE OPScans.EingAnfPoID > 0
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, AnfKo.Lieferdatum AS Lieferdatum, CONVERT(date, Eingangsscans.Zeitpunkt) AS Einlesezeitpunkt, AnfKo.AuftragsNr AS Packzettel, AnfKo.DruckZeitpunkt AS PZDruckzeitpunkt, LsKo.LsNr, LsKo.DruckZeitpunkt AS LSDruckzeitpunkt, COUNT(Eingangsscans.ID) AS Eingang, AnfPo.Angefordert, AnfPo.Geliefert AS Ausgang, AnfPo.Geliefert - AnfPo.Angefordert AS Differenz
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
LEFT OUTER JOIN Eingangsscans ON Eingangsscans.EingAnfPoID = AnfPo.ID
WHERE Kunden.ID = $ID$
  AND AnfKo.Lieferdatum BETWEEN $1$ AND $2$
  AND Vsa.Status = 'A'
  AND (AnfPo.Angefordert <> 0 OR AnfPo.Geliefert <> 0 OR AnfPo.UrAngefordert <> 0)
GROUP BY Kunden.Kdnr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, AnfKo.Lieferdatum, CONVERT(date, Eingangsscans.Zeitpunkt), AnfKo.AuftragsNr, AnfKo.DruckZeitpunkt, LsKo.LsNr, LsKo.DruckZeitpunkt, AnfPo.Angefordert, AnfPo.Geliefert

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, AnfKo.Lieferdatum AS Lieferdatum, CONVERT(date, Eingangsscans_Archiv.Zeitpunkt) AS Einlesezeitpunkt, AnfKo.AuftragsNr AS Packzettel, AnfKo.DruckZeitpunkt AS PZDruckzeitpunkt, LsKo.LsNr, LsKo.DruckZeitpunkt AS LSDruckzeitpunkt, COUNT(Eingangsscans_Archiv.ID) AS Eingang, AnfPo.Angefordert, AnfPo.Geliefert AS Ausgang, AnfPo.Geliefert - AnfPo.Angefordert AS Differenz
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN Eingangsscans_Archiv ON Eingangsscans_Archiv.EingAnfPoID = AnfPo.ID
WHERE Kunden.ID = $ID$
  AND AnfKo.Lieferdatum BETWEEN $1$ AND $2$
  AND Vsa.Status = 'A'
  AND (AnfPo.Angefordert <> 0 OR AnfPo.Geliefert <> 0 OR AnfPo.UrAngefordert <> 0)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, AnfKo.LieferDatum, CONVERT(date, Eingangsscans_Archiv.Zeitpunkt), AnfKo.AuftragsNr, AnfKo.DruckZeitpunkt, LsKo.LsNr, LsKo.DruckZeitpunkt, AnfPo.Angefordert, AnfPo.Geliefert

UNION ALL

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsKo.Datum AS Lieferdatum, CONVERT(date, NULL) AS Einlesezeitpunkt, '' AS Packzettel, CONVERT(date, NULL) AS PZDruckzeitpunkt, LsKo.LsNr, LsKo.DruckZeitpunkt AS LSDruckzeitpunkt, 0 AS Eingang, 0 AS Angefordert, LsPo.Menge AS Ausgang, LsPo.Menge * -1 AS Differenz
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Kunden.ID = $ID$
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND Vsa.Status = 'A'
  AND NOT EXISTS (SELECT AnfKo.* FROM AnfKo WHERE AnfKo.LsKoID = LsKo.ID)
ORDER BY Kunden.KdNr, VsaNr, Artikel.ArtikelNr, LieferDatum;