/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Laut Mail von Malte MAYER (03/04/2024) ist dieser Datenexport nicht notwendig                                             ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2024-04-08                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @customerarticle TABLE (
  customerid int,
  customername nvarchar(20) COLLATE Latin1_General_CS_AS,
  articleid nvarchar(15) COLLATE Latin1_General_CS_AS,
  articlename nvarchar(60) COLLATE Latin1_General_CS_AS,
  sortingcategory int,
  sortingcategorybez nvarchar(60) COLLATE Latin1_General_CS_AS,
  washingprogram nchar(8) COLLATE Latin1_General_CS_AS,
  washingprogrambez nvarchar(40) COLLATE Latin1_General_CS_AS
);

INSERT INTO @customerarticle (customerid, customername, articleid, articlename, sortingcategory, sortingcategorybez, washingprogram, washingprogrambez)
SELECT Kunden.Kdnr AS customerid, Kunden.SuchCode AS customername, Artikel.ArtikelNr AS articleid, Artikel.ArtikelBez AS articlename, WascSort.Waschsortierung AS sortingcategory, WascSort.WascSortBez AS sortingcategorybez, IIF(WaschPrg.ID = -1, NULL, WaschPrg.WaschPrg) AS washingprogram, IIF(WaschPrg.ID = -1, NULL, WaschPrg.WaschPrgBez) AS washingprogrambez
FROM WascSoPr
JOIN WascSort ON WascSoPr.WascSortID = WascSort.ID
JOIN KdArti ON WascSoPr.KdArtiID = KdArti.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN WaschPrg ON KdArti.WaschPrgID = WaschPrg.ID
WHERE WascSoPr.KdArtiID > 0;

INSERT INTO @customerarticle (customerid, customername, articleid, articlename, sortingcategory, sortingcategorybez, washingprogram, washingprogrambez)
SELECT Kunden.KdNr AS customerid, Kunden.SuchCode AS customername, Artikel.ArtikelNr AS articleid, Artikel.ArtikelBez AS articlename, WascSort.Waschsortierung AS sortingcategory, WascSort.WascSortBez AS sortingcategorybez, IIF(WaschPrg.ID = -1, NULL, WaschPrg.WaschPrg) AS washingprogram, IIF(WaschPrg.ID = -1, NULL, WaschPrg.WaschPrgBez) AS washingprogrambez
FROM WascSoPr
JOIN WascSort ON WascSoPr.WascSortID = WascSort.ID
JOIN KdArti ON WascSoPr.ArtikelID = KdArti.ArtikelID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON WascSoPr.ArtikelID = Artikel.ID
JOIN WaschPrg ON WascSoPr.WaschPrgID = WaschPrg.ID
WHERE WascSoPr.KdArtiID = -1
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND NOT EXISTS (
    SELECT customerarticle.*
    FROM @customerarticle AS customerarticle
    WHERE customerarticle.articleid = Artikel.ArtikelNr
      AND customerarticle.customerid = Kunden.KdNr
  );

SELECT * FROM @customerarticle;