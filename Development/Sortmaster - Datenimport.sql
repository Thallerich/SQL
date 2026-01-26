DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Cleanup                                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DELETE FROM WascSoPr WHERE WascSortID > 0
DELETE FROM WascSort WHERE ID > 0;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import "Waschsortierungen"                                                                                                ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH Waschsort AS (
  SELECT DISTINCT __Sortmaster.Waschsortierung
  FROM __Sortmaster
  WHERE __Sortmaster.Waschsortierung IS NOT NULL
    AND __Sortmaster.Waschsortierung != 0
)
INSERT INTO WascSort (Waschsortierung, WascSortBez, Code, AnlageUserID_, UserID_)
SELECT WaschSort.Waschsortierung,
  WaschSortBez = (
    SELECT TOP 1 Sortmaster.WaschsortierungBez
    FROM (
      SELECT __Sortmaster.Waschsortierung, __Sortmaster.WaschsortierungBez, COUNT(*) AS Anzahl
      FROM __Sortmaster
      GROUP BY __Sortmaster.Waschsortierung, __Sortmaster.WaschsortierungBez
    ) AS Sortmaster
    WHERE Sortmaster.Waschsortierung = Waschsort.Waschsortierung
    ORDER BY Sortmaster.Anzahl DESC
  ),
  CAST(WaschSort.Waschsortierung AS nvarchar),
  @userid,
  @userid
FROM WaschSort;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import "Regelwerk"                                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO WascSoPr (KdArtiID, WascSortID, SdcDevID, AnlageUserID_, UserID_)
SELECT DISTINCT KdArti.ID AS KdArtiID, WascSort.ID, 51 AS SdcDevID, @userid, @userid
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN __Sortmaster ON Artikel.ArtikelNr = __Sortmaster.ArtikelNr COLLATE Latin1_General_CS_AS AND Kunden.KdNr = __Sortmaster.KdNr AND KdArti.Variante = ISNULL(__Sortmaster.Variante, '-') COLLATE Latin1_General_CS_AS
JOIN WascSort ON __Sortmaster.Waschsortierung = WascSort.Waschsortierung
WHERE __Sortmaster.Waschsortierung IS NOT NULL
  AND __Sortmaster.Waschsortierung != 0;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import "Waschprogramme"                                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE KdArti SET WaschPrgID = SortmasterDiff.WaschPrgID, UserID_ = @userid
FROM (
  SELECT KdArti.ID AS KdArtiID, WaschPrg.ID AS WaschPrgID
  FROM KdArti
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  JOIN __Sortmaster ON Artikel.ArtikelNr = __Sortmaster.ArtikelNr COLLATE Latin1_General_CS_AS AND Kunden.KdNr = __Sortmaster.KdNr AND KdArti.Variante = __Sortmaster.Variante COLLATE Latin1_General_CS_AS
  JOIN WaschPrg ON CAST(__Sortmaster.Waschprogramm COLLATE Latin1_General_CS_AS AS nvarchar) = WaschPrg.WaschPrg
  WHERE __Sortmaster.Waschprogramm IS NOT NULL
    AND __Sortmaster.Waschprogramm != 0
) AS SortmasterDiff
WHERE SortmasterDiff.KdArtiID = KdArti.ID;