SELECT FORMAT($STARTDATE$, N'dd.MM.yyyy') AS Startdatum, FORMAT($ENDDATE$, N'dd.MM.yyyy') AS Enddatum;

SELECT FORMAT(LsKo.Datum, 'yyyy-MM') AS Monat,
  Kunden.ID AS KundenID,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kunden.AdressBlock,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  LsPo.Kostenlos,
  LsPo.EPreis AS Einzelpreis,
  SUM(LsPo.Menge) AS Menge,
  SUM(LsPo.Menge * LsPo.EPreis) AS Gesamtpreis
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Kunden.ID = $ID$
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND KdBer.BereichID IN ($2$)
  AND LsKo.[Status] >= N'O'
  AND KdArti.LSAusblenden = 0
  AND LsKo.LsKoArtID != (SELECT LsKoArt.ID FROM LsKoArt WHERE LsKoArt.Art = N'J')
GROUP BY FORMAT(LsKo.Datum, N'yyyy-MM'), Kunden.ID, Kunden.KdNr, Kunden.SuchCode, Kunden.AdressBlock, Artikel.ArtikelNr, Artikel.ArtikelBez, LsPo.Kostenlos, LsPo.EPreis
ORDER BY Monat ASC, ArtikelNr ASC;