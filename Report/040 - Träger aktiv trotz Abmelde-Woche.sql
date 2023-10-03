WITH Trägerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
)
SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Standort.SuchCode AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger AS TrägerNr, Traeger.PersNr AS Personalnummer, Trägerstatus.StatusBez AS [Status Träger], Traeger.Vorname, Traeger.Nachname, Traeger.Indienst, Traeger.Ausdienst, Traeger.ID AS TraegerID
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Trägerstatus ON Traeger.[Status] = Trägerstatus.[Status]
WHERE Traeger.[Status] = N'A'
  AND Traeger.Ausdienst IS NOT NULL
  AND Traeger.Ausdienst < (SELECT [Week].Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN [Week].VonDat AND [Week].BisDat)
  AND Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND [Zone].ID IN ($3$)
  AND Standort.ID IN ($4$);