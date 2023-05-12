WITH Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TRAEGER')
),
Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'EINZHIST')
)
SELECT DISTINCT Traeger.ID AS TraegerID, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Traeger.Titel, Traeger.PersNr, Traegerstatus.StatusBez AS Traegerstatus, CAST(IIF(TraeAppl.ArtiTypeID = 2, 1, 0) AS bit) AS NS, Traeger.Namenschild1, Traeger.Namenschild2, Traeger.Namenschild3, Traeger.SchrankInfo, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, KdArti.Variante, TraeArti.Menge, EinzHist.Barcode, Teilestatus.StatusBez AS Teilestatus, EinzHist.Eingang1, EinzHist.Ausgang1
FROM EinzHist
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Traegerstatus ON Traeger.Status = Traegerstatus.Status
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Teilestatus ON EinzHist.Status = Teilestatus.Status
LEFT JOIN TraeAppl ON TraeAppl.TraeArtiID = TraeArti.ID AND TraeAppl.ArtiTypeID = 2
WHERE Vsa.ID = $ID$
  AND EinzHist.Status IN (N'A', N'E', N'G', N'I', N'K', N'L', N'M', N'O', N'C', N'Q', N'S', N'N')
  AND Traeger.Status <> N'I'
  AND EinzHist.IsCurrEinzHist = 1
  AND EinzHist.PoolFkt = 0
  AND EinzHist.EinzHistTyp = 1
ORDER BY Traeger.Nachname, Traeger.Vorname, Artikelbezeichnung, ArtGroe.Groesse, EinzHist.Ausgang1 DESC;

/********************************************************************************************************
** Kundendaten                                                                                         **
********************************************************************************************************/

SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Vsa.ID = $ID$;