SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS [Kostenstellen-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(IIF(LsPo.Menge > 0, LsPo.Menge, 0)) AS Liefermenge,  SUM(IIF(LsPo.Menge > 0, 0, LsPo.Menge)) AS Reklamationsmenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE LsPo.ProduktionID IN ($1$)
  AND LsKo.Datum BETWEEN $2$ AND $3$
  AND Kunden.ID = $ID$
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez;