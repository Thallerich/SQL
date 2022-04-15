WITH Trägerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
)
SELECT Traeger.ID AS TraegerID, Traeger.VsaID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, Traeger.Traeger AS Trägernummer, Traeger.PersNr AS Personalnummer, Trägerstatus.StatusBez AS Trägerstatus, Traeger.Nachname, Traeger.Vorname, Traeger.Titel, Traeger.Geschlecht, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.SchrankInfo AS [Schrank-Fach], Traeger.Indienst, Traeger.Ausdienst
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Trägerstatus ON Traeger.[Status] = Trägerstatus.[Status]
WHERE Kunden.ID IN ($2$)
  AND (($3$ = 1) OR ($3$ = 0 AND Traeger.Status != N'I'))
ORDER BY KdNr, VsaNr, Trägernummer;