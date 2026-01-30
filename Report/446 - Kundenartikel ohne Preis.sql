/* Pipeline: prepareData +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

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

/* Pipeline: Reportdaten +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Firma.SuchCode AS Firma,
  KdGf.KurzBez AS SGF,
  [Zone].ZonenCode AS Transportzone,
  Standort.SuchCode AS Hauptstandort,
  Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kunden.Name1,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  Artgru.Gruppe AS Artikelgruppe,
  KdArti.Variante,
  KdArti.VariantBez AS Variantenbezeichnung,
  KdArti.Umlauf,
  KdArti.AbrechMenge AS Abrechnungsmenge,
  #Liefermenge446.Liefermenge,
  KdArtiStatus.StatusBez AS KundenartikelStatus,
  KdArti.Vorlaeufig,
  KdArti.ID AS KdArtiID,
  [Preis Aktivierungszeitpunkt] = (
    SELECT TOP 1 CAST(PrArchiv.Aktivierungszeitpunkt AS date)
    FROM PrArchiv
    WHERE PrArchiv.KdArtiID = KdArti.ID
      AND PrArchiv.Aktivierungszeitpunkt IS NOT NULL
    ORDER BY PrArchiv.Aktivierungszeitpunkt DESC
  )
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Holding ON Holding.ID = Kunden.HoldingID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN [Zone] ON Kunden.ZoneID = Zone.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Artgru ON Artikel.ArtgruID = Artgru.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KDARTI'
) AS KdArtiStatus ON KdArti.[Status] = KdArtiStatus.[Status]
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
  AND KdArti.Anlage_ > $6$
  AND KdArti.Anlage_ < $7$
  AND Kunden.Status IN (
    SELECT [Status].[Status]
    FROM [Status]
    WHERE [Status].ID IN ($3$)
  )
  AND Kunden.FirmaID IN ($1$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND (
    (
      ($5$) = 0
      AND EXISTS (
        SELECT PreisKdArti.*
        FROM KdArti AS PreisKdArti
        JOIN Artikel AS PreisArtikel ON PreisKdArti.ArtikelID = PreisArtikel.ID
        JOIN ArtGru AS PreisArtGru ON PreisArtikel.ArtGruID = PreisArtGru.ID
        WHERE PreisArtGru.Gruppe = ArtGru.Gruppe  /* prüfen auf ArtGru.Gruppe anstatt ArtGru.ID weil mehrere Einträge mit gleicher Gruppe existieren */
          AND PreisKdArti.KundenID = Kunden.ID
          AND (PreisKdArti.LeasPreis != 0 OR PreisKdArti.WaschPreis != 0)
      )
    )
    OR ($5$) = 1
  )
ORDER BY Holding.Holding, Kunden.KdNr, Artikel.ArtikelNr;