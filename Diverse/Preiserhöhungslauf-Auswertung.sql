SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vertrag.Nr AS [Vertrag-Nr], Vertrag.Bez AS Vertragsbezeichnung, Vertrag.Preisgarantie, _PELAUF._PelaufBez AS Preiserhöhungslauf
FROM Vertrag
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN _PELAUF ON Vertrag._PeLaufID = _PELAUF.ID
WHERE _PELAUF.ID IN (2, 3)
  AND Vertrag.[Status] = N'A';