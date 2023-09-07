WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
),
VsaStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VSA'
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
),
VsaPauseAktuell AS (
  SELECT VsaPause.VsaID,
    ISNULL(VsaPause.VonWoche, CAST(DATEPART(year, VsaPause.VonDatum) AS nchar(4)) + N'/' + FORMAT(DATEPART(ISO_WEEK, VsaPause.VonDatum), N'00')) AS VonWoche,
    ISNULL(VsaPause.BisWoche, CAST(DATEPART(year, VsaPause.BisDatum) AS nchar(4)) + N'/' + FORMAT(DATEPART(ISO_WEEK, VsaPause.BisDatum), N'00')) AS BisWoche,
    VsaPause.LeasRabatt
  FROM VsaPause
  WHERE (
      CAST(DATEPART(year, GETDATE()) AS nchar(4)) + N'/' + FORMAT(DATEPART(ISO_WEEK, GETDATE()), N'00') BETWEEN VsaPause.VonWoche AND VsaPause.BisWoche
      OR
      CAST(GETDATE() AS date) BETWEEN VsaPause.VonDatum AND VsaPause.BisDatum
    )
    AND VsaPause.VsaID > 0
),
TraegerPauseAktuell AS (
  SELECT VsaPause.TraegerID,
    ISNULL(VsaPause.VonWoche, CAST(DATEPART(year, VsaPause.VonDatum) AS nchar(4)) + N'/' + FORMAT(DATEPART(ISO_WEEK, VsaPause.VonDatum), N'00')) AS VonWoche,
    ISNULL(VsaPause.BisWoche, CAST(DATEPART(year, VsaPause.BisDatum) AS nchar(4)) + N'/' + FORMAT(DATEPART(ISO_WEEK, VsaPause.BisDatum), N'00')) AS BisWoche,
    VsaPause.LeasRabatt
  FROM VsaPause
  WHERE (
      CAST(DATEPART(year, GETDATE()) AS nchar(4)) + N'/' + FORMAT(DATEPART(ISO_WEEK, GETDATE()), N'00') BETWEEN VsaPause.VonWoche AND VsaPause.BisWoche
      OR
      CAST(GETDATE() AS date) BETWEEN VsaPause.VonDatum AND VsaPause.BisDatum
    )
    AND VsaPause.TraegerID > 0
)
SELECT KdGf.KurzBez AS Geschäftsfeld,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kundenstatus.StatusBez AS [Status Kunde],
  Standort.SuchCode AS Hauptstandort,
  Vsa.ID AS VsaID,  /* Für Button zum direkten Sprung in der Auswertung */
  Vsa.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  VsaStatus.StatusBez AS [Status VSA],
  Traeger.ID AS TraegerID, /* Für Button zum direkten Sprung in der Auswertung */
  Traeger.Traeger AS TrägerNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Traegerstatus.StatusBez AS [Status Träger],
  IIF(CAST(DATEPART(year, GETDATE()) AS nchar(4)) + N'/' + FORMAT(DATEPART(ISO_WEEK, GETDATE()), N'00') BETWEEN Traeger.KostenlosVon AND Traeger.KostenlosBis AND Traeger.Status = N'K', Traeger.KostenlosVon, NULL) AS [Träger kostenlos von],
  IIF(CAST(DATEPART(year, GETDATE()) AS nchar(4)) + N'/' + FORMAT(DATEPART(ISO_WEEK, GETDATE()), N'00') BETWEEN Traeger.KostenlosVon AND Traeger.KostenlosBis AND Traeger.Status = N'K', Traeger.KostenlosBis, NULL) AS [Träger kostenlos bis],
  VsaPauseAktuell.VonWoche AS [VSA-Leasingpause von],
  VsaPauseAktuell.BisWoche AS [VSA-Leasingpause bis],
  VsaPauseAktuell.LeasRabatt AS [Leasing-Rabatt während Pause],
  TraegerPauseAktuell.VonWoche AS [Träger-Leasingpause von],
  TraegerPauseAktuell.BisWoche AS [Träger-Leasingpause bis],
  TraegerPauseAktuell.LeasRabatt AS [Leasing-Rabatt während Pause]
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
JOIN VsaStatus ON Vsa.[Status] = VsaStatus.[Status]
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
LEFT JOIN VsaPauseAktuell ON Vsa.ID = VsaPauseAktuell.VsaID
LEFT JOIN TraegerPauseAktuell ON Traeger.ID = TraegerPauseAktuell.TraegerID
WHERE (Traeger.Status IN (N'K', N'P') OR VsaPauseAktuell.LeasRabatt > 0 OR TraegerPauseAktuell.LeasRabatt > 0)
  AND Traeger.[Status] != N'I'
  AND KdGf.ID IN ($1$)
  AND Standort.ID IN ($2$)
  AND EXISTS (
    SELECT VsaBer.*
    FROM VsaBer
    JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
    WHERE VsaBer.VsaID = Vsa.ID
      AND VsaBer.[Status] = N'A'
      AND KdBer.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'BK')
      AND VsaBer.ServiceID IN ($3$)
  )
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)