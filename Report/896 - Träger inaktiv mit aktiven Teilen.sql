WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TRAEGER')
)
SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS Vsa, Traeger.ID AS TraegerID, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Traegerstatus.Status AS Trägerstatus, Traeger.Ausdienst AS [Außerdienststellungswoche], Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Teilestatus.StatusBez AS Teilestatus
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
JOIN Traegerstatus ON Traeger.Status = Traegerstatus.Status
WHERE Traeger.Status = N'I'
  AND Teile.Status = N'Q'
  AND Teile.AltenheimModus = 0
  AND Traeger.Altenheim = 0
  AND Vsa.StandKonID IN (
    SELECT StandBer.StandKonID
    FROM StandBer
    WHERE StandBer.ProduktionID = $1$
      AND StandBer.BereichID = 100
  )
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Vsa.SichtbarID IN ($SICHTBARIDS$);