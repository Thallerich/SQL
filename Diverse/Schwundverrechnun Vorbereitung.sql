DECLARE @KdNr INTEGER;

@KdNr = 2710219;

/*
UPDATE OPTeile SET WegGrundID = -1, WegDatum = NULL, AusdRestwert = 0
WHERE ID IN (
  SELECT OPTeile.ID
  FROM OPTeile, Vsa, Kunden
  WHERE OPTeile.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.KdNr = @KdNr
    AND OPTeile.Status = 'W'
    AND OPTeile.RechPoID < 0
);

UPDATE OPTeile SET Status = 'Z', WegGrundID = 110, WegDatum = CURDATE()
WHERE OPTeile.VsaID IN (SELECT Vsa.ID FROM Vsa, Kunden WHERE Vsa.KundenID = Kunden.ID AND Kunden.KdNr = @KdNr)
  AND OPTeile.Code LIKE '%*'
  AND OPTeile.Status <> 'Z';

-- Abrechnung über Wochen - 2% je Monat - Abrechnung läuft über Artikelstamm;

UPDATE KdArti SET KdArti.AfaWochen = 217
WHERE ID IN (
  SELECT KdArti.ID
  FROM OPTeile, Vsa, Kunden, KdArti
  WHERE OPTeile.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND KdArti.ArtikelID = OPTeile.ArtikelID
    AND KdArti.KundenID = Kunden.ID
    AND Kunden.KdNr = @KdNr
    AND OPTeile.Status = 'W'
    AND OPTeile.RechPoID < 0
);

UPDATE Artikel SET Artikel.AfaWochen = KdArti.AfaWochen, Artikel.BasisRestwert = KdArti.BasisRestwert
FROM Artikel, (
  SELECT DISTINCT KdArti.ArtikelID, KdArti.AfaWochen, KdArti.BasisRestwert
  FROM OPTeile, Vsa, Kunden, KdArti
  WHERE OPTeile.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND KdArti.ArtikelID = OPTeile.ArtikelID
    AND KdArti.KundenID = Kunden.ID
    AND Kunden.KdNr = @KdNr
    AND OPTeile.Status = 'W'
    AND OPTeile.RechPoID < 0
) KdArti
WHERE KdArti.ArtikelID = Artikel.ID;
*/

SELECT OPTeile.*
FROM OPTeile, Vsa, Kunden
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdNr = @KdNr
  AND OPTeile.Status = 'W'
  AND OPTeile.RechPoID < 0;