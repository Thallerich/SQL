WITH LsKoStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'LSKO')
)
SELECT Kunden.KdNr, Kunden.SuchCode AS [Kunden-Stichwort], Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], LsKo.ID AS LsKoID, LsKo.LsNr, LsKo.Datum, LsKoStatus.StatusBez AS [Lieferschein-Status], LsKoArt.LsKoArtBez AS [Lieferschein-Art]
FROM LsKo
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden oN Vsa.KundenID = Kunden.ID
JOIN LsKoArt ON LsKo.LsKoArtID = LsKoArt.ID
JOIN LsKoStatus ON LsKo.[Status] = LsKoStatus.[Status]
WHERE LsKo.Datum BETWEEN $1$ AND $2$
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    WHERE Artikel.ArtikelNr = N'ZUS'
      AND LsPo.LsKoID = LsKo.ID
  )
  AND NOT EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    WHERE Artikel.ArtikelNr != N'ZUS'
      AND LsPo.LsKoID = LsKo.ID
  )
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Vsa.SichtbarID IN ($SICHTBARIDS$);