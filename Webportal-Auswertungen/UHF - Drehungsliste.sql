DECLARE @kundenid int = $kundenID;
DECLARE @webuserid int = $webuserID;
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'SELECT Kunden.KdNr AS Kundennummer, 
  Kunden.SuchCode AS  [Kunden-Stichwort], 
  Vsa.VsaNr AS [VSA-Nummer], 
  Vsa.Bez AS [VSA-Bezeichnung], 
  Artikel.ArtikelNr, 
  Artikel.ArtikelBez AS Artikelbezeichnung, 
  IIF(Bereich.VsaAnfGroe = 1, ArtGroe.Groesse, N''-'') AS Groesse, 
  VsaAnfArti.Bestand AS Vertragsbestand, 
  COUNT(EinzTeil.ID) AS [Teile beim Kunden], 
  VsaAnfArti.Bestand - COUNT(EinzTeil.ID) AS [Differenz VB - Ist], 
  SUM(IIF(DATEDIFF(day, EinzTeil.LastScanToKunde, GETDATE()) <= 7, 1, 0)) AS [stark drehend <= 7], 
  SUM(IIF(DATEDIFF(day, EinzTeil.LastScanToKunde, GETDATE()) > 7 AND DATEDIFF(day, EinzTeil.LastScanToKunde, GETDATE()) <= 30, 1, 0)) AS [schwach drehend <= 30], 
  SUM(IIF(DATEDIFF(day, EinzTeil.LastScanToKunde, GETDATE()) > 30 AND DATEDIFF(day, EinzTeil.LastScanToKunde, GETDATE()) <= 90, 1, 0)) AS [kaum drehend <= 90], 
  SUM(IIF(DATEDIFF(day, ISNULL(EinzTeil.LastScanToKunde, N''1980-01-01''), GETDATE()) > 90, 1, 0)) AS [nicht drehend > 90] 
FROM EinzTeil 
JOIN Vsa ON EinzTeil.VsaID = Vsa.ID 
JOIN Kunden ON Vsa.KundenID = Kunden.ID 
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID 
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID 
JOIN Bereich ON Artikel.BereichID = Bereich.ID 
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse 
LEFT JOIN ( 
  SELECT KdArti.ArtikelID, VsaAnf.ArtGroeID, VsaAnf.VsaID, VsaAnf.Bestand 
  FROM VsaAnf 
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID 
) AS VsaAnfArti ON VsaAnfArti.VsaID = Vsa.ID AND VsaAnfArti.ArtikelID = Artikel.ID AND (VsaAnfArti.ArtGroeID = ArtGroe.ID OR Bereich.VsaAnfGroe = 0) 
WHERE Kunden.ID = @kundenid 
  AND Vsa.ID IN ( 
    SELECT Vsa.ID 
    FROM Vsa 
    JOIN WebUser ON WebUser.KundenID = Vsa.KundenID 
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID 
    WHERE WebUser.ID = @webuserid 
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID) 
  ) 
  AND EinzTeil.Status = N''Q'' 
  AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154, 173) 
  AND Artikel.BereichID NOT IN (SELECT ID FROM Bereich WHERE Bereich IN (N''LW'', N''ST'')) 
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, IIF(Bereich.VsaAnfGroe = 1, ArtGroe.Groesse, N''-''), VsaAnfArti.Bestand, GroePo.Folge 
ORDER BY Kundennummer, [VSA-Nummer], ArtikelNr, GroePo.Folge;';

EXEC sp_executesql @sqltext, N'@kundenid int, @webuserid int', @kundenid, @webuserid;