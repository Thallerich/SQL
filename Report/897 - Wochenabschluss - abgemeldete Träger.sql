SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.Bez AS [Vsa-Bezeichnung],
  Traeger.Traeger,
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.Ausdienst,
  Fachleer.SchrankNr,
  Fachleer.FachNr,
  [Erste Tour] = (
    SELECT TOP 1 Touren.Tour
    FROM Touren
    JOIN VsaTour ON VsaTour.TourenID = Touren.ID
    JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE VsaTour.VsaID = Vsa.ID
      AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND Bereich.Bereich = N'BK'
    ORDER BY Touren.Wochentag, Touren.Tour
  ),
  [Erste Tour-Bezeichnung] = (
    SELECT TOP 1 Touren.Bez
    FROM Touren
    JOIN VsaTour ON VsaTour.TourenID = Touren.ID
    JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE VsaTour.VsaID = Vsa.ID
      AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND Bereich.Bereich = N'BK'
    ORDER BY Touren.Wochentag, Touren.Tour
  ),
  [Expedition] = (
    SELECT TOP 1 Standort.Bez
    FROM Touren
    JOIN Standort ON Touren.ExpeditionID = Standort.ID
    JOIN VsaTour ON VsaTour.TourenID = Touren.ID
    JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE VsaTour.VsaID = Vsa.ID
      AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND Bereich.Bereich = N'BK'
    ORDER BY Touren.Wochentag, Touren.Tour
  )
FROM FachLeer
JOIN Traeger ON FachLeer.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Week ON Traeger.Ausdienst = Week.Woche
WHERE Fachleer.AnlageUserID_ = (SELECT Mitarbei.ID FROM Mitarbei WHERE UserName = N'JOB')
  AND Traeger.Ausdienst IS NOT NULL
  AND Week.VonDat >= $STARTDATE$
  AND Week.BisDat <= $ENDDATE$
ORDER BY Kunden.KdNr, Vsa.VsaNr;