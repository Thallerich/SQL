DECLARE @Woche nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TEILE'
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Teile.Barcode, Teilestatus.StatusBez AS [Status des Teils], Traeger.Traeger AS TrägerNr, Traeger.Vorname, Traeger.Nachname, Traegerstatus.StatusBez AS [Status des Trägers], Abteil.Abteilung AS Kostenstele, Abteil.Bez AS Kostenstellenbezeichnung, Vsa.GebaeudeBez AS Abteilung, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, Teile.AbmeldDat AS [Datum Abmeldung], LeasProWo.LeasPreisProWo AS [Leasing pro Woche], RwCalc.RestwertInfo AS Restwert
FROM Teile
CROSS APPLY advFunc_GetLeasPreisProWo(Teile.KdArtiID) AS LeasProWo
CROSS APPLY funcGetRestwert(Teile.ID, @Woche, 1) AS RwCalc
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN KdArti ON Teile.KdArtiID = KdArti.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
JOIN Traegerstatus ON Traeger.Status = Traegerstatus.Status
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
WHERE Kunden.KdNr = 272295
  AND Teile.Status BETWEEN N'S' AND N'W'
  AND Teile.Einzug IS NULL;