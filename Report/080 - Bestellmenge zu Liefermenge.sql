/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: prepareData                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #Umlauf;
DROP TABLE IF EXISTS #Liefermenge;
DROP TABLE IF EXISTS #ResultSet;

DECLARE @CurrentWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @ProductionLocation int = $1$;
DECLARE @WarehouseLocation int = $2$;

SELECT ProduktionID, ArtikelID, SUM(Umlauf) AS Umlauf
INTO #Umlauf
FROM (
  SELECT StandBer.ProduktionID, VsaLeas.VsaID, - 1 AS TraegerID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaLeas.Menge) AS Umlauf
  FROM VsaLeas
  JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
  JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
  WHERE @CurrentWeek BETWEEN ISNULL(VsaLeas.Indienst, N'1980/01') AND ISNULL(VsaLeas.Ausdienst, N'2099/52')
    AND Artikel.BereichID IN ($3$)
  GROUP BY StandBer.ProduktionID, VsaLeas.VsaID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID

  UNION ALL

  SELECT StandBer.ProduktionID, VsaAnf.VsaID, - 1 AS TraegerID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaAnf.Bestand) AS Umlauf
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
  WHERE VsaAnf.Bestand != 0
    AND VsaAnf.[Status] = N'A'
    AND Artikel.BereichID IN ($3$)
  GROUP BY StandBer.ProduktionID, VsaAnf.VsaID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1), KdArti.ArtikelID

  UNION ALL

  SELECT StandBer.ProduktionID, Strumpf.VsaID, - 1 AS TraegerID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(Strumpf.ID) AS Umlauf
  FROM Strumpf
  JOIN Vsa ON Strumpf.VsaID = Vsa.ID
  JOIN KdArti ON Strumpf.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
  WHERE Strumpf.[Status] != N'X'
    AND ISNULL(Strumpf.Indienst, N'1980/01') >= @CurrentWeek
    AND Strumpf.WegGrundID < 0
    AND Artikel.BereichID IN ($3$)
  GROUP BY StandBer.ProduktionID, Strumpf.VsaID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID
  
  UNION ALL

  SELECT StandBer.ProduktionID, Traeger.VsaID, TraeArti.TraegerID, TraeArti.KdArtiID, TraeArti.ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
  WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
    AND Artikel.BereichID IN ($3$)

  UNION ALL

  SELECT StandBer.ProduktionID, Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
  JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
  WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
    AND KdArAppl.ArtiTypeID = 3  --Emblem
    AND Artikel.BereichID IN ($3$)

  UNION ALL

  SELECT StandBer.ProduktionID, Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
  JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
  WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
    AND KdArAppl.ArtiTypeID = 2 --Namenschild
    AND Artikel.BereichID IN ($3$)
) AS x
GROUP BY ProduktionID, ArtikelID;

SELECT KdArti.ArtikelID, FORMAT(LsKo.Datum, N'yyyy-MM') AS Monat, [Week].Woche, SUM(LsPo.Menge) AS Liefermenge
INTO #Liefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN [Week] ON LsKo.Datum BETWEEN [Week].VonDat AND [Week].BisDat
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE LsKo.Datum BETWEEN CAST(DATEADD(month, -12, GETDATE()) AS date) AND CAST(GETDATE() AS date)
  AND LsKo.ProduktionID = @ProductionLocation
  AND LsKo.[Status] >= 'O'
  AND Artikel.BereichID IN ($3$)
GROUP BY KdArti.ArtikelID, FORMAT(LsKo.Datum, N'yyyy-MM'), [Week].Woche;

SELECT Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  Artikelstatus.StatusBez AS Artikelstatus,
  [Liefermenge 12 Monate] = (
    SELECT SUM(#Liefermenge.Liefermenge)
    FROM #Liefermenge
    WHERE #Liefermenge.ArtikelID = Artikel.ID
  ),
  [Bestellmenge 12 Monate] = (
    SELECT SUM(BPo.LiefMenge)
    FROM BPo
    JOIN BKo ON BPo.BKoID = BKo.ID
    JOIN Lagerart ON BKo.LagerartID = Lagerart.ID
    JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
    WHERE ArtGroe.ArtikelID = Artikel.ID
      AND Lagerart.LagerID = @WarehouseLocation
      AND BKo.Datum BETWEEN CAST(DATEADD(month, -12, GETDATE()) AS date) AND CAST(GETDATE() AS date)
      AND BKo.[Status] IN (N'J', N'M')
  ),
  [Bestellmenge offen] = (
    SELECT SUM(BPo.Menge - BPo.LiefMenge)
    FROM BPo
    JOIN BKo ON BPo.BKoID = BKo.ID
    JOIN Lagerart ON BKo.LagerartID = Lagerart.ID
    JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
    WHERE ArtGroe.ArtikelID = Artikel.ID
      AND Lagerart.LagerID = @WarehouseLocation
      AND BKo.[Status] IN (N'F', N'J')
      AND BPo.LiefMenge < BPo.Menge
  ),
  Umlaufmenge = (
    SELECT #Umlauf.Umlauf
    FROM #Umlauf
    WHERE #Umlauf.ArtikelID = Artikel.ID
      AND #Umlauf.ProduktionID = @ProductionLocation
  ),
  [EK-Preis] = (
    SELECT TOP 1 ArtiLief.EkPreis
    FROM ArtiLief
    WHERE ArtiLief.ArtikelID = Artikel.ID
      AND (
        (
          ArtiLief.StandortID = (SELECT ID FROM Standort WHERE SuchCode = N'SMZL')
          AND ArtiLief.LiefID = (SELECT TOP 1 LiefID FROM LiefPrio WHERE LiefPrio.ArtikelID = ArtiLief.ArtikelID AND LiefPrio.StandortID = ArtiLief.StandortID)
          AND CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
        )
        OR
        (
          ArtiLief.StandortID = (SELECT ID FROM Standort WHERE SuchCode = N'SMZL')
          AND NOT EXISTS (
            SELECT a.*
            FROM ArtiLief AS a
            WHERE a.ArtikelID = ArtiLief.ArtikelID
              AND a.StandortID = (SELECT ID FROM Standort WHERE SuchCode = N'SMZL')
              AND a.LiefID = (SELECT TOP 1 LiefID FROM LiefPrio WHERE LiefPrio.ArtikelID = a.ArtikelID AND LiefPrio.StandortID = a.StandortID)
              AND CAST(GETDATE() AS date) BETWEEN ISNULL(a.VonDatum, N'1980-01-01') AND ISNULL(a.BisDatum, N'2099-12-31')
          )
          AND CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
        )
        OR
        (
          ArtiLief.StandortID = -1
          AND ArtiLief.LiefID = Artikel.LiefID
          AND NOT EXISTS (
            SELECT a.*
            FROM ArtiLief AS a
            WHERE a.ArtikelID = ArtiLief.ArtikelID
              AND a.StandortID = (SELECT ID FROM Standort WHERE SuchCode = N'SMZL')
              AND CAST(GETDATE() AS date) BETWEEN ISNULL(a.VonDatum, N'1980-01-01') AND ISNULL(a.BisDatum, N'2099-12-31')
          )
        )
      )
    ORDER BY ArtiLief.VonDatum DESC
  ),
  [TLM-Spitze] = (
    SELECT TOP 1 TLMMenge.Liefermenge / 20
    FROM (
      SELECT #Liefermenge.Monat, SUM(#Liefermenge.Liefermenge) AS Liefermenge
      FROM #Liefermenge
      WHERE #Liefermenge.ArtikelID = Artikel.ID
      GROUP BY #Liefermenge.Monat
    ) AS TLMMenge
    ORDER BY TLMMenge.Liefermenge DESC
  ),
  [TLM letzte 4 Wochen] = (
    SELECT SUM(TLMMenge.Liefermenge) / 20
    FROM (
      SELECT TOP 4 #Liefermenge.Liefermenge
      FROM #Liefermenge
      WHERE #Liefermenge.ArtikelID = Artikel.ID
        AND #Liefermenge.Woche < @CurrentWeek
      ORDER BY #Liefermenge.Woche DESC
    ) AS TLMMenge
  )
INTO #ResultSet
FROM Artikel
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'ARTIKEL'
) AS Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
WHERE Artikel.BereichID IN ($3$)
  AND Artikel.ArtiTypeID = 1
  AND Artikel.[Status] < N'E';

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Reportdaten                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT ArtikelNr,
  Artikelbezeichnung,
  Artikelstatus,
  [Bestellmenge offen],
  [Bestellmenge 12 Monate],
  [Liefermenge 12 Monate],
  [Bestellmenge zu Liefermenge %] = ROUND(IIF(ISNULL([Bestellmenge 12 Monate], 0) = 0, 0, 100 * ISNULL([Bestellmenge 12 Monate], 0) / ISNULL([Liefermenge 12 Monate], 1)), 2),
  Umlaufmenge,
  [EK-Preis],
  [TLM-Spitze],
  [TLM letzte 4 Wochen]
FROM #ResultSet
WHERE [Liefermenge 12 Monate] IS NOT NULL
  OR [Bestellmenge 12 Monate] IS NOT NULL
  OR [Bestellmenge offen] IS NOT NULL
  OR Umlaufmenge IS NOT NULL;