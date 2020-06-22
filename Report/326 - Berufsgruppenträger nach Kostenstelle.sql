WITH Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TRAEGER')
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger AS TraegerNr, Traegerstatus.StatusBez AS Trägerstatus, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, KdArti.VariantBez AS Berufsgruppe
FROM Traeger
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON Traeger.BerufsgrKdArtiID = KdArti.ID
JOIN Traegerstatus ON Traeger.Status = Traegerstatus.Status
WHERE Traeger.BerufsgrKdArtiID > 0
  AND Traeger.Status != N'I';