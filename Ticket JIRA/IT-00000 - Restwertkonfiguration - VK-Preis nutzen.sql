DECLARE @RW TABLE (
  RwConfigID int,
  RwConfPoID int
);

INSERT INTO @RW
SELECT RwConfig.ID AS RwConfigID, RwConfPo.ID AS RwConfPoID
FROM RwConfig
JOIN RwConfPo ON RwConfPo.RwConfigID = RwConfig.ID
WHERE RwConfig.RueckVar = 1
  AND RwConfig.RueckVarTausch = 1
  AND RwConfPo.RwArtID = 6
  AND RwConfPo.UseKdArtiVkPreis = 0;

UPDATE RwConfig SET RKoTypeID = -2
WHERE ID IN (
    SELECT RwConfigID FROM @RW
  )
  AND RKoTypeID IN (-1, 1);

UPDATE RwConfPo SET UseKdArtiVkPreis = 1
WHERE ID IN (
    SELECT RwConfPoID FROM @RW
  )
  AND UseKdArtiVkPreis != 1;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, KdArti.VkPreis AS Verkaufspreis
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE Kunden.RWConfigID IN (
    SELECT RWConfig.ID
    FROM RwConfig
    JOIN RwConfPo ON RwConfPo.RwConfigID = RwConfig.ID
    WHERE RwConfPo.RwArtID = 6
      AND RwConfPo.UseKdArtiVkPreis = 1
  )
  AND KdArti.KaufwareModus > 0
  AND Bereich.BK = 1;