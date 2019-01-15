WITH Kundenstatus AS (
  SELECT [Status].[Status], [Status].StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Firma.Bez AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS Kundenstatus, Vertrag.Nr AS VertragNr, Vertrag.Bez AS Vertrag, Vertrag.Preisgarantie, _PELAUF._PelaufBez AS Preiserhöhungslauf
FROM Vertrag
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN _PELAUF ON Vertrag._PeLaufID = _PELAUF.ID
WHERE Firma.SuchCode = N'SAL';