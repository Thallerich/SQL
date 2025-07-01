SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Bereich.BereichBez$LAN$ AS Produktbereich, Vsa.ID AS VsaID, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], StandKon.StandKonBez$LAN$ AS Standortkonfig, Vsa.Name1 AS [Adresszeile 1], Vsa.Name2 AS [Adresszeile 2], Vsa.Name3 AS [Adresszeile 3], Vsa.Strasse, Vsa.Land, Vsa.PLZ, Vsa.Ort, Touren.Tour, Touren.Bez AS Tourbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, LsPo.EPreis AS Bearbeitungspreis, Kunden.VertragWaeID AS Bearbeitungspreis_WaeID, SUM(LsPo.Menge) AS Liefermenge, CAST(SUM(LsPo.Menge * LsPo.EPreis * IIF(LsPo.Kostenlos = 1, 0, 1)) AS money) AS Umsatz, Kunden.VertragWaeID AS Umsatz_WaeID, LsKo.Datum, RechWae.Code AS Rechnungswährung
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Touren ON Fahrt.TourenID = Touren.ID
JOIN Wae AS RechWae ON Kunden.RechWaeID = RechWae.ID
WHERE LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Bereich.ID IN ($2$)
  AND Touren.ID IN ($3$)
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND StandKon.ID IN ($4$)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Bereich.BereichBez$LAN$, Vsa.ID, Vsa.VsaNr, Vsa.Bez, StandKon.StandKonBez$LAN$, Vsa.Name1, Vsa.Name2, Vsa.Name3, Vsa.Strasse, Vsa.Land, Vsa.PLZ, Vsa.Ort, Touren.Tour, Touren.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsPo.EPreis, Kunden.VertragWaeID, LsKo.Datum, RechWae.Code;