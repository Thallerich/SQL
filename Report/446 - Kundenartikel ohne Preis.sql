DROP TABLE IF EXISTS #Liefermenge446;

CREATE TABLE #Liefermenge446 (
  KdArtiID int,
  Liefermenge numeric(18,4)
);

INSERT INTO #Liefermenge446 (KdArtiID, Liefermenge)
SELECT LsPo.KdArtiID, SUM(LsPo.Menge) AS Liefermenge
FROM LsPo
WHERE LsPo.LsKoID IN (
  SELECT LsKo.ID
  FROM LsKo
  WHERE LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
    AND LsKo.VsaID IN (
      SELECT Vsa.ID
      FROM Vsa
      WHERE Vsa.KundenID IN (
        SELECT Kunden.ID
        FROM Kunden
        WHERE Kunden.KdGFID IN ($2$)
          AND Kunden.FirmaID IN ($1$)
          AND Kunden.SichtbarID IN ($SICHTBARIDS$)
          AND Kunden.Status IN (
            SELECT [Status].[Status]
            FROM [Status]
            WHERE [Status].ID IN ($3$)
          )
      )
    )
)
GROUP BY LsPo.KdArtiID;

WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KDARTI'
)
SELECT Firma.SuchCode AS Firma,
  KdGf.KurzBez AS SGF,
  [Zone].ZonenCode AS Transportzone,
  Standort.SuchCode AS Hauptstandort,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kunden.Name1,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  KdArti.Variante,
  KdArti.VariantBez AS Variantenbezeichnung,
  KdArti.Umlauf,
  KdArti.AbrechMenge AS Abrechnungsmenge,
  #Liefermenge446.Liefermenge,
  KdArtiStatus.StatusBez AS KundenartikelStatus,
  KdArti.Vorlaeufig,
  KdArti.ID AS KdArtiID
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN [Zone] ON Kunden.ZoneID = Zone.ID
JOIN KdArtiStatus ON KdArti.[Status] = KdArtiStatus.[Status]
LEFT JOIN #Liefermenge446 ON #Liefermenge446.KdArtiID = KdArti.ID
WHERE KdArti.KundenID = Kunden.ID
  AND Kunden.KdgfID = KdGf.ID
  AND Kunden.FirmaID = Firma.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArtiStatus.Status = KdArti.Status
  AND Kunden.ZoneID = [Zone].ID
  AND Kunden.StandortID = Standort.ID
  AND KdGf.ID IN ($2$)
  AND KdArti.LeasPreis = 0  
  AND KdArti.WaschPreis = 0 
  AND KdArti.Status = N'A'
  AND (($4$ = 0 AND KdArti.Vorlaeufig = 0) OR ($4$ = 1))
  AND Kunden.Status IN (
    SELECT [Status].[Status]
    FROM [Status]
    WHERE [Status].ID IN ($3$)
  )
  AND Kunden.FirmaID IN ($1$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr, Artikel.ArtikelNr;