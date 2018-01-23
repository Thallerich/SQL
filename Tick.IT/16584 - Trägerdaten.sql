SELECT Traeger.ID AS TraegerID, Status.StatusBez AS Status, Traeger.Traeger, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Traeger.Titel, Traeger.Indienst, Traeger.Ausdienst, Traeger.SchrankInfo AS FachNr, Traeger.NS, Traeger.Emblem, Vsa.VsaNr, Vsa.Bez AS [VSA-Name], Abteil.Bez AS Kostenstelle, Abteil.Abteilung AS Kostenstellenkürzel, KdArti.VariantBez AS Berufsgruppe, Traeger.RentomatKarte AS Chipkartennummer, RentoCod.Bez AS Funktionscode, KdAussta.Bez AS Ausstattung
FROM Traeger, Vsa, Abteil, KdArti, RentoCod, KdAussta, (
  SELECT Status.Status, Status.StatusBez$LAN$ AS StatusBez
  FROM Status
  WHERE Status.Tabelle = 'TRAEGER'
) AS Status
WHERE Traeger.VsaID = Vsa.ID
  AND Traeger.AbteilID = Abteil.ID
  AND Traeger.BerufsgrKdArtiID = KdArti.ID
  AND Traeger.RentoCodID = RentoCod.ID
  AND Traeger.KdAusstaID = KdAussta.ID
  AND Traeger.Status = Status.Status
  AND Vsa.ID = $ID$;