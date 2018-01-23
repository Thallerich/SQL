UPDATE Teile SET RentomatChip = Barcode
WHERE ID IN (
  SELECT Teile.ID
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  WHERE Vsa.RentomatID IN (23, 24, 26, 28, 29, 30, 45)  --KHBG-Unimaten
    AND Teile.RentomatChip IS NULL
    AND Teile.Status IN ('M', 'N', 'Q')

  UNION ALL

  SELECT Teile.ID
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN Artikel ON Teile.ArtikelID = Artikel.ID
  WHERE Vsa.StandKonID = 202 --Budweis
    AND Artikel.ChipCodes = 1
    AND Teile.RentomatChip IS NULL
    AND Teile.Status IN ('M', 'N', 'Q')
    AND Teile.AltenheimModus = 0
); 