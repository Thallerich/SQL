UPDATE Teile SET Einzug = '31.12.2013'
WHERE ID IN (
  SELECT Teile.ID
  FROM Teile, Vsa, Kunden, KdGf
  WHERE Teile.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.KdGfID = KdGf.ID
    AND KdGf.KurzBez = 'HO'
    AND Teile.Status IN ('U', 'W')
    AND Teile.Einzug IS NULL
    AND Teile.AusdienstDat < '01.01.2014'
);

UPDATE Kunden SET RWGutschriftWo = 2, GutschriftFtAbWo = '2014/01'
WHERE ID IN (
  SELECT Kunden.ID
  FROM Kunden, KdGf
  WHERE Kunden.KdGfID = KdGf.ID
    AND KdGf.KurzBez = 'HO'
);