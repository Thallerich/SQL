DECLARE @kdnr int = 10001756;
DECLARE @sourcevsanr int = 1;
DECLARE @destinationvsanr int = 51;

DECLARE @sourcevsaid int, @destinationvsaid int;

SELECT @sourcevsaid = Vsa.ID
FROM Vsa
WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @kdnr)
  AND Vsa.VsaNr = @sourcevsanr;

SELECT @destinationvsaid = Vsa.ID
FROM Vsa
WHERE Vsa.KundenID = (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr = @kdnr)
  AND Vsa.VsaNr = @destinationvsanr;

UPDATE EinzTeil SET VsaID = @destinationvsaid
WHERE ID IN (
  SELECT EinzTeil.ID
  FROM EinzTeil
  JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
  WHERE EinzTeil.VsaID = @sourcevsaid
    AND (Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'FW') OR Artikel.ArtikelNr IN (N'54A7L', N'54A7XL'))
);