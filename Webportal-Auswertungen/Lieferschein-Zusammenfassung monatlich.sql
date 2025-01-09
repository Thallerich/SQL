DECLARE @kundenid int, @webuserid int, @vondat date, @bisdat date;
DECLARE @sqltext nvarchar(max);

SELECT @kundenid = $kundenID, @webuserid = $webuserID, @vondat = CAST($vonDat AS date), @bisdat = CAST($bisDat AS date);

SET @sqltext = N'
SELECT @vondat AS VonDatum,
  @bisdat AS BisDatum,
  FORMAT(LsKo.Datum, ''yyyy-MM'') AS Monat,
  Kunden.ID AS KundenID,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kunden.AdressBlock,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  LsPo.Kostenlos,
  LsPo.EPreis AS Einzelpreis,
  SUM(LsPo.Menge) AS Menge,
  SUM(LsPo.Menge * LsPo.EPreis) AS Gesamtpreis
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Kunden.ID = @kundenid
  AND LsKo.VsaID IN (  
    SELECT Vsa.ID
    FROM Vsa
    JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = @webuserid
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  )
  AND LsPo.AbteilID IN (  
    SELECT WebUAbt.AbteilID
    FROM WebUAbt
    WHERE WebUAbt.WebUserID = @webuserid
  )
  AND LsKo.Datum BETWEEN @vondat AND @bisdat
  AND KdBer.BereichID IN ($bereichIDs)
  AND LsKo.[Status] >= N''O''
  AND KdArti.LSAusblenden = 0
  AND LsKo.LsKoArtID != (SELECT LsKoArt.ID FROM LsKoArt WHERE LsKoArt.Art = N''J'')
GROUP BY FORMAT(LsKo.Datum, N''yyyy-MM''), Kunden.ID, Kunden.KdNr, Kunden.SuchCode, Kunden.AdressBlock, Artikel.ArtikelNr, Artikel.ArtikelBez, LsPo.Kostenlos, LsPo.EPreis
ORDER BY Monat ASC, ArtikelNr ASC;
';

EXEC sp_executesql @sqltext, N'@kundenid int, @webuserid int, @vondat date, @bisdat date', @kundenid, @webuserid, @vondat, @bisdat;