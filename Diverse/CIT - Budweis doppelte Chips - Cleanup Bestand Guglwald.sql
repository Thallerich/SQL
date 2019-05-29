SELECT OPTeile.*
FROM OPTeile
WHERE OPTeile.ArtikelID IN (
    SELECT Artikel.ID
    FROM Artikel
    WHERE Artikel.ArtikelNr IN (N'313700MC', N'323700MC', N'333700MC', N'344000MC', N'710160MC', N'770101MC', N'780101MC')
  )
  AND OPTeile.VsaID IN (
    SELECT Vsa.ID
    FROM Vsa
    WHERE Vsa.KundenID IN (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr IN (242013, 2710136))
  )
  AND OPTeile.LastActionsID = 102
  AND OPTeile.LastScanTime < N'2019-05-29 00:00:00';