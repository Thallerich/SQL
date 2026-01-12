/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-102561                                                                                                                 ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2026-01-12                                                                                       ++ */
/* ++ Pipeline: prepareData           																																							            ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #TempPersonalliste;

SELECT VsaID = Vsa.ID,
       TraegerID = Traeger.ID,
			 Woche = Wochen.Woche,
			 TrägerNr = Traeger.Traeger,
			 PersNr = Traeger.PersNr,
			 Nachname = Traeger.Nachname,
			 Vorname = Traeger.Vorname,
			 Menge = TraeArch.Menge,
			 Größe = ArtGroe.Groesse,
			 Schrank = (
			   SELECT TOP 1 SchrankNr
				 FROM Schrank, TraeFach
				 WHERE TraeFach.SchrankID = Schrank.ID
					 AND TraeFach.TraegerID = Traeger.ID
			 ),
			 Fach = (
	       SELECT TOP 1 Fach
	       FROM TraeFach
	       WHERE Traeger.ID = TraegerID
       ),
			 ArtikelNr = Artikel.ArtikelNr,
			 Artikelbezeichnung = Artikel.ArtikelBez,
			 Variante = KdArti.Variante,
			 Variantenbezeichnung = KdArti.VariantBez,
			 Kunde = Kunden.Name1,
			 VSA = ISNULL(Vsa.Bez + N' (', N'(') + ISNULL(Vsa.SuchCode, N'') + N')',
			 Kostenstelle = Abteil.Abteilung,
			 Kostenstellenbezeichnung = Abteil.Bez
INTO #TempPersonalliste
FROM TraeArch
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON TraeArch.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON TraeArch.AbteilID = Abteil.ID
JOIN Wochen ON TraeArch.WochenID = Wochen.ID
JOIN [Week] ON Wochen.Woche = [Week].Woche
WHERE TraeArch.ApplKdArtiID = -1
	AND Kunden.ID = $2$
	AND [Week].VonDat >= $STARTDATE$
	AND [Week].BisDat <= $ENDDATE$;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ IT-102561                                                                                                                 ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2026-01-12                                                                                       ++ */
/* ++ Pipeline: Personalliste         																																							            ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @pivotcols nvarchar(max), @pivotcolsheader nvarchar(max), @pivotsql nvarchar(max);

SET @pivotcols = STUFF((SELECT DISTINCT N', [' + Woche + N']' FROM #TempPersonalliste ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');
SET @pivotcolsheader = STUFF((SELECT DISTINCT N', ISNULL([' + Woche + N'], 0) AS [Menge ' + Woche + N']' FROM #TempPersonalliste ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '');

SET @pivotsql = N'SELECT VsaID, TraegerID, Kunde, VSA, TrägerNr, PersNr, Nachname, Vorname, Schrank, Fach, Kostenstelle, Kostenstellenbezeichnung, ArtikelNr, Artikelbezeichnung, Größe, Variante, Variantenbezeichnung, ' + @pivotcolsheader + N'
FROM #TempPersonalliste AS PersList
PIVOT (SUM(Menge) FOR Woche IN (' + @pivotcols + N')) AS PersListPivot';

EXEC sp_executesql @pivotsql;