DROP TABLE IF EXISTS #PersListMatrixAbtKdArW, #PersListMatrix;

SELECT DISTINCT AbtKdArW.ID, AbtKdArW.LeasPrKzID, AbtKdArW.RechPoID
INTO #PersListMatrixAbtKdArW
FROM AbtKdArW
JOIN TraeArch ON TraeArch.AbtKdArWID = AbtKdArW.ID
WHERE TraeArch.LeasPrKzID != 3
  AND TraeArch.ApplKdArtiID = -1
  AND TraeArch.AbteilID IN (
    SELECT RechPo.AbteilID
    FROM RechPo
    WHERE RechPo.RechKoID = $RECHKOID$
    )
  AND TraeArch.WochenID IN (
    SELECT AbtKdArW.WochenID
    FROM AbtKdArW
    WHERE AbtKdArW.RechPoID IN (
      SELECT RechPo.ID
      FROM RechPo
      WHERE RechPo.RechKoID = $RECHKOID$
    )
  );

SELECT
  Kunden.KdNr,
  Vsa.VsaNr,
  Vsa.Bez AS VsaBezeichnung,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Traeger.Traeger,
  Traeger.PersNr,
  COALESCE(Traeger.Nachname + N', ', N'') + COALESCE(Traeger.Vorname, N'') AS FullName,
  IIF(TraeArch.ApplKdArtiID > 0, ApplArtikel.ArtikelNr, Artikel.ArtikelNr) AS ArtikelNr,
  IIF(TraeArch.ApplKdArtiID > 0, '- ' + ApplArtikel.ArtikelBez$LAN$, Artikel.ArtikelBez$LAN$) AS ArtikelBez,
  ArtGroe.Groesse,
  Wochen.Woche,
  SUM(TraeArch.Menge) AS Menge
INTO #PersListMatrix
FROM Traeger
LEFT JOIN KdArti AS BerufsgrKdArti ON Traeger.BerufsgrKdArtiID = BerufsgrKdArti.ID AND Traeger.BerufsgrKdArtiID > - 1
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN TraeArch ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Abteil ON TraeArch.AbteilID = Abteil.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Vsa ON TraeArch.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN KdArti AS ApplKdArti ON TraeArch.ApplKdArtiID = ApplKdArti.ID
JOIN Artikel AS ApplArtikel ON ApplKdArti.ArtikelID = ApplArtikel.ID
JOIN Wochen ON TraeArch.WochenID = Wochen.ID
JOIN #PersListMatrixAbtKdArW AS AbtKdArW ON TraeArch.AbtKdArWID = AbtKdArW.ID
CROSS JOIN (
  SELECT RechKo.ID, RechKo.Debitor, RechKo.VonDatum, RechKo.BisDatum, RechKo.RechWaeID
  FROM RechKo
  WHERE RechKo.ID = $RECHKOID$
) AS RechKo
JOIN Wae AS RechWae ON RechKo.RechWaeID = RechWae.ID
WHERE TraeArch.LeasPrKzID != 3
  AND TraeArch.ApplKdArtiID = -1
  AND TraeArch.AbteilID IN (
    SELECT RechPo.AbteilID
    FROM RechPo
    WHERE RechPo.RechKoID = $RECHKOID$
    )
  AND TraeArch.WochenID IN (
    SELECT AbtKdArW.WochenID
    FROM AbtKdArW
    WHERE AbtKdArW.RechPoID IN (
      SELECT RechPo.ID
      FROM RechPo
      WHERE RechPo.RechKoID = $RECHKOID$
    )
  )
GROUP BY
  Kunden.KdNr,
  Vsa.VsaNr,
  Vsa.Bez,
  Abteil.Abteilung,
  Abteil.Bez,
  Traeger.Traeger,
  Traeger.PersNr,
  COALESCE(Traeger.Nachname + N', ', N'') + COALESCE(Traeger.Vorname, N''),
  IIF(TraeArch.ApplKdArtiID > 0, ApplArtikel.ArtikelNr, Artikel.ArtikelNr),
  IIF(TraeArch.ApplKdArtiID > 0, '- ' + ApplArtikel.ArtikelBez, Artikel.ArtikelBez),
  ArtGroe.Groesse,
  Wochen.Woche;

DECLARE @pivotcols nvarchar(max), @pivotsum nvarchar(max), @pivotsql nvarchar(max);

SET @pivotcols = STUFF((SELECT DISTINCT ', [' + Woche + ']' FROM #PersListMatrix ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
SET @pivotsum = STUFF((SELECT DISTINCT ' + ISNULL([' + Woche + '], 0)' FROM #PersListMatrix ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,2,'');

SET @pivotsql = N'
SELECT KdNr, VsaNr, VsaBezeichnung AS [Vsa-Bezeichnung], Kostenstelle, Kostenstellenbezeichnung, Traeger AS Trägernummer, PersNr AS Personalnummer, FullName AS Trägername, ArtikelNr AS Artikelnummer, ArtikelBez AS Artikelbezeichnung, Groesse AS Größe, ' + @pivotcols + N', ' + @pivotsum + N' AS Gesamtmenge
FROM #PersListMatrix AS PersListPivot
PIVOT (SUM(Menge) FOR Woche IN (' + @pivotcols + N')) AS p
ORDER BY Kostenstelle, Trägernummer, Artikelnummer, Größe;
';

EXEC sp_executesql @pivotsql;