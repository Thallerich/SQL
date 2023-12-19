DECLARE @KdArti TABLE (
  ID int PRIMARY KEY CLUSTERED
);

INSERT INTO @KdArti (ID)
SELECT KdArti.ID
FROM KdArti
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
WHERE KdArti.[Status] = N'A'
  AND EXISTS (
    SELECT Vsa.*
    FROM Vsa
    JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID
    WHERE Vsa.KundenID = KdArti.KundenID
      AND StandBer.BereichID = KdBer.BereichID
      AND StandBer.ProduktionID IN ($1$)
      AND Vsa.[Status] = N'A'
  );

SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.VariantBez AS Variante, KdArti.AbrechMenge AS [Abrechnungsmenge für Miete], KdArti.WaschPreis AS Bearbeitungspreis, Kunden.VertragWaeID AS Bearbeitungspreis_WaeID, LeasProWoche.LeasPreis AS Mietpreis_wöchentlich, Kunden.VertragWaeID AS Mietpreis_wöchentlich_WaeID,
  Preistyp =
    CASE
      WHEN KdArti.WaschPreis != 0 AND KdArti.LeasPreis != 0 THEN N'Splitting'
      WHEN KdArti.WaschPreis != 0 AND KdArti.LeasPreis = 0 THEN N'Bearbeitung'
      WHEN KdArti.WaschPreis = 0 AND KdArti.LeasPreis != 0 THEN N'Miete'
      WHEN KdArti.WaschPreis = 0 AND KdArti.LeasPreis = 0 THEN N'Kostenlos'
    END,
  KdArti.ID AS KdArtiID
FROM @KdArti
JOIN KdArti ON [@KdArti].ID = KdArti.ID
CROSS APPLY advFunc_GetLeasPreisProWo(KdArti.ID) AS LeasProWoche
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
WHERE Kunden.[Status] = N'A'
  AND (($2$ = 0 AND (KdArti.WaschPreis != 0 OR KdArti.LeasPreis != 0)) OR $2$ = 1);