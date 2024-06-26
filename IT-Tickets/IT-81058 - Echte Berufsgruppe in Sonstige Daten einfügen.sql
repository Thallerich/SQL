WITH DataUpdate AS (
  SELECT Traeger.ID AS TraegerID, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, KdArti.VariantBez AS Berufsgruppe, Traeger.VormalsNr AS Sonstiges, _IT81058.BGreal
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN KdArti ON Traeger.BerufsgrKdArtiID = KdArti.ID
  JOIN Abteil ON Traeger.AbteilID = Abteil.ID
  JOIN _IT81058 ON _IT81058.VsaNr = Vsa.VsaNr AND _IT81058.Traeger = Traeger.Traeger AND _IT81058.Vorname = Traeger.Vorname AND _IT81058.Nachname = Traeger.Nachname AND _IT81058.KsSt = Abteil.Abteilung AND ISNULL(_IT81058.PersNr, N'') = ISNULL(Traeger.PersNr, N'')
  WHERE Vsa.KundenID = (SELECT ID FROM Kunden WHERE KdNr = 19010)
)
UPDATE Traeger SET VormalsNr = DataUpdate.BGreal
FROM DataUpdate
WHERE DataUpdate.TraegerID = Traeger.ID
  AND Traeger.VormalsNr IS NULL;

/*
TRUNCATE TABLE _IT81058;
*/