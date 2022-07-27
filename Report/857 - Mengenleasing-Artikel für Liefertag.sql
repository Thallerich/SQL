DECLARE @curweek nchar(7) = (SELECT Week.Woche FROM Week WHERE GETDATE() BETWEEN Week.VonDat AND Week.BisDat);

WITH FirstVsaTour AS (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, MIN(Touren.Wochentag) AS Wochentag
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  WHERE GETDATE() BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
  GROUP BY VsaTour.VsaID, VsaTour.KdBerID
),
LiefermengeSchnitt AS (
  SELECT LsKo.VsaID, LsPo.KdArtiID, SUM(LsPo.Menge) AS Liefermenge, COUNT(DISTINCT LsKo.Datum) AS LiefertageAnzahl
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum >= DATEADD(week, -4, GETDATE())
  GROUP BY LsKo.VsaID, LsPo.KdArtiID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.VariantBez AS Variante, VsaLeas.Menge AS Liefermenge, JahrLief.Lieferwochen,
  Wochentag = 
    CASE FirstVsaTour.Wochentag
      WHEN 1 THEN N'Montag'
      WHEN 2 THEN N'Dienstag'
      WHEN 3 THEN N'Mittwoch'
      WHEN 4 THEN N'Donnerstag'
      WHEN 5 THEN N'Freitag'
      WHEN 6 THEN N'Samstag'
      WHEN 7 THEN N'Sonntag'
      ELSE N'WFT!?'
    END,
  [Liefermenge Schnitt 4 Wochen] = ISNULL(ROUND(LiefermengeSchnitt.Liefermenge / LiefermengeSchnitt.LiefertageAnzahl, 0), 0)
FROM VsaLeas
JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN JahrLief ON JahrLief.TableID = VsaLeas.ID AND JahrLief.TableName = N'VSALEAS' AND JahrLief.Jahr = YEAR(GETDATE())
LEFT JOIN FirstVsaTour ON FirstVsaTour.VsaID = Vsa.ID AND FirstVsaTour.KdBerId = KdArti.KdBerID
LEFT JOIN LiefermengeSchnitt ON LiefermengeSchnitt.VsaID = Vsa.ID AND LiefermengeSchnitt.KdArtiID = KdArti.ID
WHERE Kunden.StandortID IN ($1$)
  AND Artikel.ID IN ($2$)
  AND FirstVsaTour.Wochentag IN ($3$)
  AND @curweek BETWEEN VsaLeas.InDienst AND ISNULL(VsaLeas.AusDienst, N'2099/52')
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);