SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, VsaAnf.Bestand
FROM VsaAnf, Vsa, Kunden, KdArti, Artikel
WHERE VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.ID = $kundenID
  AND VsaAnf.Bestand > 0
  AND VsaAnf.Status <> 'I'
  AND Vsa.Status = 'A'
  AND Vsa.ID IN (  
    SELECT Vsa.ID
    FROM Vsa
    JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = $webuserID
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  )
  AND VsaAnf.AbteilID IN (  
    SELECT WebUAbt.AbteilID
    FROM WebUAbt
    WHERE WebUAbt.WebUserID = $webuserID
  )
ORDER BY Kunden.KdNr, [VSA-Nummer], Artikel.ArtikelNr;