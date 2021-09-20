IF $liefdat < DATEADD(month, -2, GETDATE())
  SELECT N'Die Daten stehen nur bis zu 2 Monate in die Vergangenheit zur Verfügugung. Bitte wählen Sie ein anderes Datum' AS VSA, NULL AS [bestellte Menge]
ELSE
  SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, SUM(AnfPo.Angefordert) AS [bestellte Menge], Vsa.SuchCode AS VSA, Vsa.Bez AS Versandanschrift, Abteil.Abteilung AS KsSt, Abteil.Bez AS Kostenstelle, AnfKo.LieferDatum AS Lieferdatum
  FROM AnfPo
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN Vsa ON AnfKo.VsaID = Vsa.ID
  JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Abteil ON AnfPo.AbteilID = Abteil.ID
  WHERE Vsa.KundenID = $kundenID
    AND AnfKo.Lieferdatum = $liefdat
    AND Abteil.ID IN (
      SELECT WebUAbt.AbteilID
      FROM WebUAbt
      WHERE WebUAbt.WebUserID = $webuserID
    )
    AND Vsa.ID IN (  
      SELECT Vsa.ID
      FROM Vsa
      JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
      LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
      WHERE WebUser.ID = $webuserID
        AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
    
    )
    AND AnfPo.Angefordert != 0
  GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, Vsa.SuchCode, Vsa.Bez, Abteil.Abteilung, Abteil.Bez, AnfKo.LieferDatum
  ORDER BY VSA, ArtikelNr;