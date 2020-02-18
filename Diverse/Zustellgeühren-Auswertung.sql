WITH ZUSKd AS (
  SELECT DISTINCT KdArti.KundenID, CAST(1 AS bit) AS ZUSExists
  FROM KdArti
  WHERE KdArti.ArtikelID = (SELECT ID FROM Artikel WHERE ArtikelNr = N'ZUS')
)
SELECT Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.WaschPreis AS Bearbeitungspreis, KdArti.LeasingPreis AS Leasingpreis, Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Standort.SuchCode AS Hauptstandort, ISNULL(ZUSKd.ZUSExists, 0) AS [Artikel ZUS vorhanden?]
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
LEFT OUTER JOIN ZUSKd ON ZUSKd.KundenID = Kunden.ID
WHERE (UPPER(Artikel.ArtikelBez) LIKE N'%ZUSTELL%' OR UPPER(Artikel.ArtikelBez) LIKE N'%ANFAHR%' OR Artikel.ArtikelNr LIKE N'ZUS%')
  AND Artikel.ArtikelNr != N'ZUS'
  AND KdArti.[Status] = N'A'
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND KdGf.KurzBez != N'INT';