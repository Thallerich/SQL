DECLARE @customerarticle TABLE (
  customerid int,
  customername nvarchar(20),
  articleid int,
  articlename nvarchar(60),
  sortingcategory nvarchar(60),
  washingprogram nvarchar(40)
);

INSERT INTO @customerarticle (customerid, customername, articleid, articlename, sortingcategory, washingprogram)
SELECT Kunden.ID AS customerid, Kunden.SuchCode AS customername, Artikel.ID AS articleid, Artikel.ArtikelBez AS articlename, WascSort.WascSortBez AS sortingcategory, IIF(WaschPrg.ID = -1, NULL, WaschPrg.WaschPrgBez) AS washingprogram
FROM WascSoPr
JOIN WascSort ON WascSoPr.WascSortID = WascSort.ID
JOIN KdArti ON WascSoPr.KdArtiID = KdArti.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN WaschPrg ON KdArti.WaschPrgID = WaschPrg.ID
WHERE WascSoPr.KdArtiID > 0;

INSERT INTO @customerarticle (customerid, customername, articleid, articlename, sortingcategory, washingprogram)
SELECT Kunden.ID AS customerid, Kunden.SuchCode AS customername, Artikel.ID AS articleid, Artikel.ArtikelBez AS articlename, WascSort.WascSortBez AS sortingcategory, IIF(WaschPrg.ID = -1, NULL, WaschPrg.WaschPrgBez) AS washingprogram
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
    WHERE customerarticle.articleid = Artikel.ID
      AND customerarticle.customerid = Kunden.ID
  );

SELECT * FROM @customerarticle;