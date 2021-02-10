DROP TABLE IF EXISTS #VsaAnfahrt;

SELECT DISTINCT Vsa.ID VsaID, KdBer.BereichID, Touren.ExpeditionID, Tage.Datum, CAST(LEFT(Week.Woche, 4) AS int) Jahr, CAST(SUBSTRING(Week.Woche, 6, 2) AS int) KW, CAST(0 AS bit) AS Anfahrt, WochentagDetail = 
  CASE Touren.Wochentag
    WHEN 1 THEN N'Montag'
    WHEN 2 THEN N'Dienstag'
    WHEN 3 THEN N'Mittwoch'
    WHEN 4 THEN N'Donnerstag'
    WHEN 5 THEN N'Freitag'
    WHEN 6 THEN N'Samstag'
    WHEN 7 THEN N'Sonntag'
    ELSE N'WTF?!'
  END
INTO #VsaAnfahrt
FROM VsaTour 
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN Tage ON CAST(Touren.Wochentag AS int) = DATEPART(weekday, Tage.Datum) - 1
JOIN Week ON Tage.Datum BETWEEN Week.VonDat AND Week.BisDat
WHERE Tage.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND (VsaTour.Holen = 1 OR VsaTour.Bringen = 1)
  AND Touren.ExpeditionID IN ($1$)
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND VsaTour.BisDatum >= $ENDDATE$;

UPDATE #VsaAnfahrt SET Anfahrt = 1
FROM JahrLief
WHERE JahrLief.TableName = N'VSA'
  AND JahrLief.TableId = #VsaAnfahrt.VsaId
  AND JahrLief.Jahr = #VsaAnfahrt.Jahr
  AND SUBSTRING(JahrLief.Lieferwochen, #VsaAnfahrt.KW, 1) IN (N'X', N'L');

DELETE FROM #VsaAnfahrt
WHERE Anfahrt = 0;

WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
),
VsaStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'VSA')
)
SELECT Kunden.ID AS KundenID, Kunden.SuchCode + N' (' + CAST(Kunden.KdNr AS nvarchar) + N')' AS Kunde, Kundenstatus.StatusBez AS StatusKunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez Vsa, VsaStatus.StatusBez AS StatusVSA, Bereich.Bereich, Bereich.BereichBez$LAN$ AS BereichBez, VsaAnfahrt.Datum, VsaAnfahrt.WochentagDetail
FROM #VsaAnfahrt AS VsaAnfahrt
JOIN Vsa ON VsaAnfahrt.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Bereich ON VsaAnfahrt.BereichID = Bereich.ID
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN VsaStatus ON Vsa.Status = VsaStatus.Status
WHERE Bereich.ID IN ($2$)
ORDER BY KdNr, VsaNr, Bereich, Datum;