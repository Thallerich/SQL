/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++  - Führende Nullen entfernen, wenn ArtikelNr länger als 11 Zeichen                                                        ++ */
/* ++  - Sonderzeichen entfernen                                                                                                ++ */
/* ++    - Ausnahme: Punkt wird durch Unterstrich ersetzt, Unterstrich wird beibehalten                                         ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2019-05-13                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/*
CREATE FUNCTION [dbo].[RemoveNonAlphaNumeric] (@ToClean nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
  DECLARE @KeepValues AS nvarchar(12) = ('%[^a-z0-9_]%');
  WHILE PATINDEX(@KeepValues, @ToClean) > 0
    SET @ToClean = STUFF(@ToClean, PATINDEX(@KeepValues, @ToClean), 1, '');
  Return @ToClean;
END;

GO
 */

 /*
 DROP FUNCTION [dbo].[RemoveNonAlphaNumeric];
 GO
*/
DROP TABLE IF EXISTS #TmpCleanArti;

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, dbo.RemoveNonAlphaNumeric(REPLACE(SUBSTRING(Artikel.ArtikelNr, PATINDEX('%[^0]%',Artikel.ArtikelNr), 15), N'.', N'_')) AS CleanArtikelNr
INTO #TmpCleanArti
FROM Artikel
WHERE (Artikel.ArtikelNr LIKE N'0%' AND LEN(Artikel.ArtikelNr) > 11)
  OR Artikel.ArtikelNr LIKE N'%.%'

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez, CleanArti.CleanArtikelNr, CleanArti.ArtikelNr AS ArtNrKollision
FROM Artikel
JOIN #TmpCleanArti AS CleanArti ON CleanArti.CleanArtikelNr = Artikel.ArtikelNr COLLATE Latin1_General_CS_AS;