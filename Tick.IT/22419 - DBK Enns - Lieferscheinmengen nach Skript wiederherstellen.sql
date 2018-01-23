DECLARE @LsFix TABLE (
  LsPoID int,
  LsKoID int,
  KdNr int,
  VsaNr int,
  Vsa nvarchar(40),
  LsNr int,
  Datum date,
  ArtikelNr nchar(15),
  Artikelbezeichnung nvarchar(60),
  Menge float,
  [Anzahl Ausgelesen] int
)

INSERT INTO @LsFix
SELECT LsPo.ID AS LsPoID, LsKo.ID AS LsKoID, Kunden.KdNr, Vsa.VsaNr, Vsa.Bez AS Vsa, LsKo.LsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, LsPo.Menge, COUNT(DISTINCT Scans.TeileID) AS [Anzahl Ausgelesen]
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
LEFT OUTER JOIN Scans ON Scans.LsPoID = LsPo.ID
WHERE Kunden.KdNr IN (20125, 24045)
  AND LsKo.Datum >= CAST(N'2017-12-28' AS date) 
  AND LsKo.Memo LIKE N'%Mengen per Script%'
GROUP BY LsPo.ID, LsKo.ID, Kunden.KdNr, Vsa.VsaNr, Vsa.Bez, LsKo.LsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez, LsPo.Menge

UPDATE LsPo SET Menge = LsFix.[Anzahl Ausgelesen]
FROM LsPo
JOIN @LsFix LsFix ON LsFix.LsPoID = LsPo.ID

UPDATE LsKo SET Memo = NULL WHERE ID IN (SELECT DISTINCT LsKoID FROM @LsFix)