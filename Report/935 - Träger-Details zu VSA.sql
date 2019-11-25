WITH Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TRAEGER')
),
Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
)
SELECT Traeger.ID AS TraegerID, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Traeger.Titel, Traeger.PersNr, Traegerstatus.StatusBez AS Traegerstatus, Traeger.NS, Traeger.Namenschild1, Traeger.Namenschild2, Traeger.Namenschild3, Traeger.SchrankInfo, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, KdArti.Variante, TraeArti.Menge, Teile.Barcode, Teilestatus.StatusBez AS Teilestatus, Teile.Eingang1, Teile.Ausgang1
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Traegerstatus ON Traeger.Status = Traegerstatus.Status
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
WHERE Vsa.ID = $ID$
  AND Teile.Status IN (N'A', N'E', N'G', N'I', N'K', N'L', N'M', N'O', N'C', N'Q', N'S', N'N')
  AND Traeger.Status <> N'I'
ORDER BY Traeger.Nachname, Traeger.Vorname, Artikelbezeichnung, ArtGroe.Groesse, Teile.Ausgang1 DESC;

/********************************************************************************************************
** Kundendaten                                                                                         **
********************************************************************************************************/

SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Vsa.ID = $ID$;