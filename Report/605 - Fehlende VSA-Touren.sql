DROP TABLE IF EXISTS #TmpCheck148;
DROP TABLE IF EXISTS #TmpCheck148b;

SELECT DISTINCT Schrank.KdArtiID, Schrank.VsaID
INTO #TmpCheck148
FROM Schrank, [Week]
WHERE [Week].VonDat <= CAST(GETDATE() AS date)
  AND [Week].BisDat >= CAST(GETDATE() AS date)
  AND ISNULL(Schrank.Ausdienst, N'2099/52') > Week.Woche
  AND Schrank.ID > 0

UNION

SELECT DISTINCT VsaLeas.KdArtiID, VsaLeas.VsaID
FROM VsaLeas, [Week]
WHERE Week.VonDat <= CAST(GETDATE() AS date)
  AND Week.BisDat >= CAST(GETDATE() AS date)
  AND ISNULL(VsaLeas.Ausdienst, N'2099/52') > Week.Woche
  AND VsaLeas.ID > 0

UNION

SELECT DISTINCT VsaAnf.KdArtiID, VsaAnf.VsaID
FROM VsaAnf
WHERE VsaAnf.Art != N'm'
  AND VsaAnf.[Status] < N'I'
  aND VsaAnf.ID > 0

UNION

SELECT DISTINCT Strumpf.KdArtiID, Strumpf.VsaID
FROM Strumpf
WHERE Strumpf.[Status] < N'X'
  AND Strumpf.ID > 0

UNION

SELECT DISTINCT EinzHist.KdArtiID, EinzHist.VsaID
FROM EinzHist
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
WHERE EinzHist.[Status] BETWEEN N'A' AND N'Q'
  AND Traeger.[Status] != N'I'
  AND EinzHist.ID > 0
  
UNION

SELECT DISTINCT KdArti.ID AS KdArtiID, Contain.HistVsaID AS VsaID
FROM Contain
JOIN KdArti ON Contain.HistKundenID = KdArti.KundenID
WHERE KdArti.ArtikelID = (SELECT ISNULL(CAST(Settings.ValueMemo AS int), -1) FROM Settings WHERE Settings.Parameter = N'ID_ARTIKEL_CONTNICHTABGEGEBEN')
  AND KdArti.LeasPreis != 0
  
UNION

SELECT DISTINCT KdArti.ID AS KdArtiID, Vsa.ID AS VsaID
FROM KdArti
JOIN Vsa ON Vsa.KundenID = KdArti.KundenID
WHERE KdArti.ArtikelID = (SELECT ISNULL(CAST(Settings.ValueMemo AS int), -1) FROM Settings WHERE Settings.Parameter = N'ID_ARTIKEL_FACHMIETE')
  AND KdArti.ArtikelID > 0
  AND KdArti.Status = N'A'
  AND EXISTS( -- Nur VSAs mit Fachbelegungen mit gleicher Schrank.KdArti.Variante
    SELECT TOP 1 TraeFach.ID 
    FROM TraeFach
    JOIN Traeger ON TraeFach.TraegerID = Traeger.ID
    JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
    JOIN KdArti SchrankKdArti ON Schrank.KdArtiID = SchrankKdArti.ID
    WHERE TraeFach.TraegerID > 0 
      AND Traeger.VsaID = Vsa.ID 
      AND Traeger.Status = N'A'
      AND SchrankKdArti.Variante = KdArti.Variante
  )

UNION

SELECT DISTINCT KdArti.ID AS KdArtiID, Vsa.ID AS VsaID
FROM KdArti
JOIN Vsa ON Vsa.KundenID = KdArti.KundenID
WHERE KdArti.ArtikelID = (SELECT ISNULL(CAST(Settings.ValueMemo AS int), -1) FROM Settings WHERE Settings.Parameter = 'ID_ARTIKEL_FACHSERVICE')
  AND KdArti.ArtikelID > 0
  AND KdArti.Status = N'A'
  AND EXISTS( -- Nur VSAs mit Fachbelegungen mit gleicher Schrank.KdArti.Variante
    SELECT TOP 1 TraeFach.ID 
    FROM TraeFach
    JOIN Traeger ON TraeFach.TraegerID = Traeger.ID
    JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
    JOIN KdArti SchrankKdArti ON Schrank.KdArtiID = KdArti.ID
    WHERE TraeFach.TraegerID > 0 
      AND Traeger.VsaID = Vsa.ID 
      AND Traeger.Status = N'A'
      AND SchrankKdArti.Variante = KdArti.Variante
  );

SELECT DISTINCT x.VsaID, KdArti.KdBerID, 1 FehlModus
INTO #TmpCheck148b
FROM #TmpCheck148 x, Vsa, KdArti
WHERE x.KdArtiID = KdArti.ID
  AND x.VsaID = Vsa.ID
  AND NOT EXISTS (SELECT ID FROM VsaTour WHERE VsaTour.VsaID = Vsa.ID AND VsaTour.KdBerID = KdArti.KdBerID)

UNION

SELECT DISTINCT x.VsaID, KdArti.KdBerID, 2 FehlModus
FROM #TmpCheck148 x, Vsa, KdArti
WHERE x.KdArtiID = KdArti.ID
  AND x.VsaID = Vsa.ID
  AND EXISTS (SELECT ID FROM VsaTour WHERE VsaTour.VsaID = Vsa.ID AND VsaTour.KdBerID = KdArti.KdBerID)
  AND NOT EXISTS (SELECT ID FROM VsaTour WHERE VsaTour.VsaID = Vsa.ID AND VsaTour.KdBerID = KdArti.KdBerID AND VsaTour.Holen = 1)

UNION

SELECT DISTINCT x.VsaID, KdArti.KdBerID, 3 FehlModus
FROM #TmpCheck148 x, Vsa, KdArti
WHERE x.KdArtiID = KdArti.ID
  AND x.VsaID = Vsa.ID
  AND EXISTS (SELECT ID FROM VsaTour WHERE VsaTour.VsaID = Vsa.ID AND VsaTour.KdBerID = KdArti.KdBerID)
  AND NOT EXISTS (SELECT ID FROM VsaTour WHERE VsaTour.VsaID = Vsa.ID AND VsaTour.KdBerID = KdArti.KdBerID AND VsaTour.Bringen = 1);

SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS Stichwort, Vsa.Bez AS [VSA-Bezeichnung], Bereich.BereichBez$LAN$ AS Bereich,
  CASE x.FehlModus
  WHEN 1 THEN 'keine VSA-Tour'
  WHEN 2 THEN 'keine VSA-Tour (holen)'
  WHEN 3 THEN 'keine VSA-Tour (bringen)'
  END AS Fehler,
  (Coalesce(RTRIM(Mitarbei.Vorname), '') + IIF(Mitarbei.Vorname is not null, ' ', '') + Coalesce(RTRIM(Mitarbei.Nachname), '')) Kundenservice
FROM #TmpCheck148B x, Vsa, Kunden, KdBer, VsaBer, Bereich, Mitarbei
WHERE x.KdBerID = KdBer.ID
  AND x.VsaID = Vsa.ID
  AND KdBer.KundenID = Kunden.ID
  AND KdBer.BereichID = Bereich.ID
  AND VsaBer.KdBerID = KdBer.ID
  AND VsaBer.VsaID = Vsa.ID
  AND Kunden.Status = 'A'
  AND VSA.Status = 'A'
  AND KdBer.Status = 'A'
  AND VsaBer.Status = 'A'
  AND KdBer.ServiceID = Mitarbei.ID
  AND Kunden.FirmaID IN ($1$)
  AND Kunden.KdNr NOT IN (4, 25202, 25206, 25207, 25208, 30005, 39999, 99998, 99999, 99997, 999999) --Testkunden / interne Kunden
ORDER BY Kunden.KdNr, Vsa.VsaNr, Bereich;