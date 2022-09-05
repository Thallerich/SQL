SELECT DISTINCT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Zone.ZonenCode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode, DrLauf.Bez AS Drucklauf, BrLauf.BrLaufBez$LAN$ AS Bearbeitungsrechnungslauf, Kunden.MonatAbgeschl AS [letzter abgeschlossener Monat], LsKo.ID AS LsKoID, LsKo.LsNr, LsKo.Datum, LsKoStatus.StatusBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsPo.Menge, LsPo.EPreis, KdArti.WaschPreis AS [Bearbeitungspreis Kundenartikel], LsPo.Anlage_ AS [Position erstellt], LsKo.DruckZeitpunkt AS [Lieferschein gedruckt]
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'LSKO')
) AS LsKoStatus ON LsKo.[Status] = LsKoStatus.[Status]
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN DrLauf ON Kunden.DrLaufID = DrLauf.ID
JOIN BrLauf ON Kunden.BrLaufID = BrLauf.ID
WHERE Firma.ID IN ($2$)
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND KdGf.ID IN ($3$)
  AND DrLauf.ID IN ($4$)
  AND BrLauf.ID IN ($5$)
  AND LsPo.RechPoID = -1
  AND LsPo.Menge * IIF(LsPo.EPreis != 0, LsPo.EPreis, KdArti.WaschPreis) != 0
  AND LsPo.Kostenlos = 0
  AND Kunden.KdNr NOT IN (2300, 6060) /* Ausnahme lt. SvobKu - Kunden mit Berufsgruppen-Faktura, Rechnung wird hier immer storniert! */;