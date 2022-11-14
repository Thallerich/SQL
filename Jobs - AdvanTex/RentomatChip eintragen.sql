UPDATE EinzHist SET RentomatChip = Barcode
WHERE ID IN (
  SELECT EinzHist.ID
  FROM EinzHist
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  WHERE Vsa.RentomatID IN (23, 24, 26, 28, 29, 30, 45)  --KHBG-Unimaten
    AND EinzHist.RentomatChip IS NULL
    AND EinzHist.Status IN ('M', 'N', 'Q')

  UNION ALL

  SELECT EinzHist.ID
  FROM EinzHist
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
  WHERE Vsa.StandKonID = 202 --Budweis
    AND Artikel.ChipCodes = 1
    AND EinzHist.RentomatChip IS NULL
    AND EinzHist.Status IN ('M', 'N', 'Q')
    AND EinzHist.AltenheimModus = 0
);