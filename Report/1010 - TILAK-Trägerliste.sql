WITH TeileIst AS (
  SELECT Teile.TraeArtiID, COUNT(Teile.ID) AS IstMenge
  FROM Teile
  WHERE Teile.Status BETWEEN N'Q' AND N'W'
    AND Teile.Einzug IS NULL
  GROUP BY Teile.TraeArtiID
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
)
SELECT Vsa.GebaeudeBez AS Gebäude, Vsa.Bez AS [Vsa-Bezeichnung], Abteil.Bez AS Kostenstelle, Traeger.SchrankInfo AS [Schrank-Fach], Traeger.Nachname, Traeger.Vorname, Traegerstatus.StatusBez AS [Status Träger], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, TraeArti.Menge AS [Max-Bestand], ISNULL(TeileIst.IstMenge, 0) AS Umlaufmenge, TraeArti.Menge - ISNULL(TeileIst.IstMenge, 0) AS Differenz
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
JOIN Traegerstatus ON Traeger.Status = Traegerstatus.Status
LEFT JOIN TeileIst ON TraeArti.ID = TeileIst.TraeArtiID
WHERE Kunden.ID = $ID$
  AND (TraeArti.Menge != 0 OR ISNULL(TeileIst.IstMenge, 0) != 0)
ORDER BY [Vsa-Bezeichnung], Nachname, Vorname, ArtikelNr, Artikelbezeichnung, GroePo.Folge;