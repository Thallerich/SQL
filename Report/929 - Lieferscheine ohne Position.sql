WITH LsKoStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'LSKO')
)
SELECT Kunden.KdNr, Kunden.SuchCode, Standort.Bez AS Hauptstandort, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Fahrt.ID AS FahrtNr, Touren.Tour, Expedition.Bez AS Expeditionsstandort, LsKo.ID AS LsKoID, LsKo.LsNr, LsKo.Datum AS Lieferdatum, LsKoStatus.StatusBez AS [Lieferschein-Status]
FROM LsKo
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Touren ON Fahrt.TourenID = Touren.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Standort AS Expedition ON Fahrt.ExpeditionID = Expedition.ID
JOIN LsKoStatus ON LsKo.Status = LsKoStatus.Status
WHERE Fahrt.ExpeditionID = $1$
  AND LsKo.Datum BETWEEN $2$ AND $3$
  AND NOT EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    WHERE LsPo.LsKoID = LsKo.ID
      AND Artikel.ArtikelNr <> N'ZUS'
  )
ORDER BY Kunden.KdNr, Vsa.VsaNr, Lieferdatum;