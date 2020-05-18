WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TEILE')
),
LsProTeil AS (
  SELECT Scans.TeileID, COUNT(DISTINCT LsKo.ID) AS AnzLS
  FROM Scans
  JOIN LsPo ON Scans.LsPoID = LsPo.ID
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum BETWEEN N'2020-01-01' AND N'2020-01-31'
  GROUP BY Scans.TeileID
)
SELECT Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  VSA.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Schrank.SchrankNr,
  TraeFach.Fach,
  Traeger.Traeger,
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.PersNr,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse,
  KdArti.Variante,
  KdArti.VariantBez AS Variantenbezeichnung,
  TraeArti.Menge AS [Max. Bestand],
  Teile.Barcode,
  CAST(IIF(Teile.Status > N'Q', 1, 0) AS bit) AS Stilllegung,
  Teilestatus.StatusBez AS Teilestatus,
  Teile.Eingang1,
  Teile.Ausgang1,
  Teile.IndienstDat AS [Letztes Einsatzdatum],
  Teile.RuecklaufG AS [Waschzyklen],
  KdArti.WaschPreis AS Bearbeitung,
  KdArti.LeasingPreis AS Leasing,
  ISNULL(LsProTeil.AnzLS, 0) AS [Anzahl Lieferscheine Jänner 2020],
  [Anzahl Leasing-Wochen Jänner 2020] = (
     SELECT COUNT(Week.Woche)
    FROM Week
    WHERE Week.Woche BETWEEN IIF(Teile.Indienst < N'2020/01', N'2020/01', Teile.Indienst) AND IIF(ISNULL(Teile.Ausdienst, N'2099/52') < N'2020/06', Teile.Ausdienst, N'2020/05')
  ),
  KdArti.WaschPreis * ISNULL(LsProTeil.AnzLS, 0) AS [Umsatz Bearbeitung],
  [Umsatz Leasing] = KdArti.LeasingPreis * (
    SELECT COUNT(Week.Woche)
    FROM Week
    WHERE Week.Woche BETWEEN IIF(Teile.Indienst < N'2020/01', N'2020/01', Teile.Indienst) AND IIF(ISNULL(Teile.Ausdienst, N'2099/52') < N'2020/06', Teile.Ausdienst, N'2020/05')
  ),
  [Umsatz gesamt] = (KdArti.WaschPreis * ISNULL(LsProTeil.AnzLS, 0)) + (KdArti.LeasingPreis * (
    SELECT COUNT(Week.Woche)
    FROM Week
    WHERE Week.Woche BETWEEN IIF(Teile.Indienst < N'2020/01', N'2020/01', Teile.Indienst) AND IIF(ISNULL(Teile.Ausdienst, N'2099/52') < N'2020/06', Teile.Ausdienst, N'2020/05')
  ))
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
LEFT OUTER JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
LEFT OUTER JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
JOIN Teilestatus ON Teile.Status = Teilestatus.Status
LEFT OUTER JOIN LsProTeil ON LsProTeil.TeileID = Teile.ID
WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
  --AND Kunden.ID IN ($2$)
  --AND Vsa.ID IN ($3$)
  --AND Teile.Status BETWEEN N'Q' AND N'W'
  --AND Teile.Einzug IS NULL
  AND Teile.Indienst < N'2020/06'
  AND (Teile.Ausdienst >= N'2020/01' OR Teile.Ausdienst IS NULL)
/* GROUP BY Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Schrank.SchrankNr,
  TraeFach.Fach,
  Traeger.Traeger,
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.PersNr,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  ArtGroe.Groesse,
  KdArti.Variante,
  KdArti.VariantBez,
  TraeArti.Menge,
  Teile.Barcode,
  CAST(IIF(Teile.Status > N'Q', 1, 0) AS bit),
  Teilestatus.Statusbez,
  Teile.Eingang1,
  Teile.Ausgang1,
  Teile.IndienstDat,
  Teile.RuecklaufG */
ORDER BY KdNr, VsaNr, Traeger, ArtikelNr, Groesse;