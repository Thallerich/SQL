BEGIN TRY
  DROP TABLE #TmpCheck148;
END TRY
BEGIN CATCH
END CATCH;

SELECT DISTINCT KdArtiID, VsaID
INTO #TmpCheck148
FROM Schrank, Week
WHERE Week.VonDat >= GETDATE()
  AND Week.BisDat <= GETDATE()
  AND ISNULL(Schrank.Ausdienst,'2099/52') > Week.Woche

UNION

SELECT DISTINCT KdArtiID, VsaID
FROM VsaLeas, Week
WHERE Week.VonDat >= GETDATE()
  AND Week.BisDat <= GETDATE()
  AND ISNULL(VsaLeas.Ausdienst,'2099/52') > Week.Woche

UNION

SELECT DISTINCT KdArtiID, VsaID
FROM VsaAnf

UNION

SELECT DISTINCT KdArtiID, VsaID
FROM Strumpf

UNION

SELECT DISTINCT KdArtiID, VsaID
FROM Teile
WHERE Status >= 'A'
  AND Status <= 'Q';

BEGIN TRY
  DROP TABLE #TmpCheck148B;
END TRY
BEGIN CATCH
END CATCH;

SELECT DISTINCT x.VsaID, KdArti.KdBerID, 1 FehlModus
INTO #TmpCheck148B
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
  AND NOT EXISTS (SELECT ID FROM VsaTour WHERE VsaTour.VsaID = Vsa.ID AND VsaTour.KdBerID = KdArti.KdBerID AND VsaTour.Holen = $TRUE$)

UNION

SELECT DISTINCT x.VsaID, KdArti.KdBerID, 3 FehlModus
FROM #TmpCheck148 x, Vsa, KdArti
WHERE x.KdArtiID = KdArti.ID
  AND x.VsaID = Vsa.ID
  AND EXISTS (SELECT ID FROM VsaTour WHERE VsaTour.VsaID = Vsa.ID AND VsaTour.KdBerID = KdArti.KdBerID)
  AND NOT EXISTS (SELECT ID FROM VsaTour WHERE VsaTour.VsaID = Vsa.ID AND VsaTour.KdBerID = KdArti.KdBerID AND VsaTour.Bringen = $TRUE$);

SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS Stichwort, Vsa.Bez AS [VSA-Bezeichnung], Bereich.BereichBez$LAN$ AS Bereich,
  CASE x.FehlModus
  WHEN 1 THEN 'keine VSA-Tour'
  WHEN 2 THEN 'keine VSA-Tour (holen)'
  WHEN 3 THEN 'keine VSA-Tour (bringen)'
  END AS Fehler,
  (ISNULL(RTRIM(Mitarbei.Vorname), '') + IIF(Mitarbei.Vorname is not null, ' ', '') + ISNULL(RTRIM(Mitarbei.Nachname), '')) Kundenservice
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