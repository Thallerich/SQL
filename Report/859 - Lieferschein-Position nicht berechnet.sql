WITH LsKoStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'LSKO')
)
SELECT DISTINCT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Zone.ZonenCode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode, Kunden.MonatAbgeschl AS [letzter abgeschlossener Monat], LsKo.ID AS LsKoID, LsKo.LsNr, LsKo.Datum, LsKoStatus.StatusBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, LsPo.Menge, LsPo.EPreis, KdArti.WaschPreis AS [Bearbeitungspreis Kundenartikel]
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN LsKoStatus ON LsKo.[Status] = LsKoStatus.[Status]
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE Firma.ID IN ($2$)
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND KdGf.ID IN ($3$)
  AND LsPo.RechPoID = -1
  AND LsPo.Menge * IIF(LsPo.EPreis != 0, LsPo.EPreis, KdArti.WaschPreis) != 0
  AND LsPo.Kostenlos = 0;