WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
),
Lagerendkontrolle AS (
  SELECT MAX(Scans.[DateTime]) AS Zeitpunkt, Scans.TeileID
  FROM Scans
  WHERE Scans.ActionsID = 49
  GROUP BY Scans.TeileID
)
SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS [Trägernummer], Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS [Größe], Teilestatus.StatusBez AS [aktueller Teile-Status], Teile.Barcode, Teile.Anlage_ AS [Anlage-Zeitpunkt], Teile.PatchDatum, CAST(Lagerendkontrolle.Zeitpunkt AS date) AS Lagerendkontrolle, Teile.IndienstDat AS [Indienststellungs-Datum]
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
JOIN GroePo ON GroePo.Groesse = ArtGroe.Groesse AND GroePo.GroeKoID = Artikel.GroeKoID
LEFT JOIN Lagerendkontrolle ON Lagerendkontrolle.TeileID = Teile.ID
WHERE Teile.Anlage_ BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
ORDER BY Firma, Geschäftsbereich, KdNr, VsaNr, [Trägernummer], ArtikelNr, GroePo.Folge;