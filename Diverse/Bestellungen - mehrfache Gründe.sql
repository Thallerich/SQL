WITH Bestellstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'BKO')
)
SELECT BKo.BestNr AS Bestellnummer, BKo.Datum AS Bestelldatum, Bestellstatus.StatusBez AS [Status der Bestellung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, BPo.BestMenge AS Bestellmenge, BPo.LiefMenge AS [bereits geliefert]
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN Bestellstatus ON Bestellstatus.Status = BKo.Status
RIGHT JOIN Teile ON Teile.BPoID = BPo.ID
WHERE Lief.LiefNr = 100
  AND BKo.Datum >= N'2020-03-16'
  AND BKo.Status IN (N'F', N'J')
  AND BPo.Menge > BPo.LiefMenge
GROUP BY BKo.BestNr, BKo.Datum, Bestellstatus.StatusBez, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, BPo.BestMenge, BPo.LiefMenge
HAVING COUNT(DISTINCT 
  CASE Teile.EinsatzGrund
    WHEN N'1' THEN N'ERST'
    WHEN N'2' THEN N'ERST'
    WHEN N'3' THEN N'ERST'
    WHEN N'4' THEN N'ERST'
    WHEN N'5' THEN N'STAND'
    ELSE N'INT'
  END
) > 1
ORDER BY Bestellnummer, ArtikelNr, Artikelbezeichnung, Groesse;