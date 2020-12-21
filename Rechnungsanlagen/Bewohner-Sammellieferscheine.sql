SELECT Kunden.ID AS KundenID, Kunden.KdNr AS Kundennummer, Vsa.ID AS VsaID, Vsa.Bez AS VsaBezeichnung, SammelLsKo.LsNr AS SammelLsNr, SammelLsKo.Datum AS SammelLsDatum, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LiefArt.LiefArt AS Auslieferart, SUM(LsPo.Menge) AS Liefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN LsKo AS SammelLsKo ON LsKo.SammelLsKoID = SammelLsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Abteil ON LsPo.AbteilID = Abteil.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Vsa ON SammelLsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE RechKo.ID = $RECHKOID$
  AND LsKo.SammelLsKoID > 0
GROUP BY Kunden.ID, Kunden.KdNr, Vsa.ID, Vsa.Bez, SammelLsKo.LsNr, SammelLsKo.Datum, Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LiefArt.LiefArt
ORDER BY SammelLsDatum ASC, Kostenstelle ASC, Artikelnummer ASC;