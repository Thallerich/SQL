TRY
	DROP TABLE #TmpPersList;
CATCH ALL END;

SELECT Abteil.Abteilung, Abteil.Bez AbteilBez, Abteil.KundenID, Daten.AbteilID, Daten.VsaID, Traeger.Traeger, Traeger.PersNr, Kunden.KdNr, Vsa.VsaNr, KdBer.ID KdBerID, RTRIM(IFNULL(Traeger.Nachname, '')) + IIF(Traeger.Vorname IS NULL, '', ', ' + RTRIM(Traeger.Vorname)) TraegerName, Artikel.ArtikelNr, LangBez.Bez, Daten.Groesse, (
	SELECT TRIM(schrank.Schranknr) + '/' + RIGHT('000'+RTRIM(CONVERT(TraeFach.Fach,SQL_CHAR)),3)
	FROM Schrank, TraeFach
	WHERE Schrank.ID = TraeFach.SchrankID 
		AND TraeFach.ID = Daten.TraeFachID
) Schrankfach, Daten.Menge, Daten.Betrag
INTO #TmpPersList
FROM Abteil, Traeger, Artikel, LangBez, Vsa, Kunden, KdBer, (
	SELECT TraeArti.TraegerID, TraeArti.KdArtiID, ArtGroe.ArtikelID, TraeArch.AbteilID, TraeArch.VsaID, ArtGroe.Groesse, (
		SELECT IFNULL(MIN(ID), -1)
		FROM TraeFach
		WHERE TraeFach.TraegerID = TraeArti.TraegerID
	) TraeFachID, SUM(TraeArch.Menge) Menge, SUM(TraeArch.WoPa) Betrag
	FROM TraeArti, TraeArch, ArtGroe, Wochen
	WHERE TraeArch.WochenID = Wochen.ID
		AND Wochen.Woche = $2$
		AND TraeArch.TraeArtiID = TraeArti.ID 
		AND TraeArti.ArtGroeID = ArtGroe.ID 
		AND TraeArch.KundenID = $ID$
	GROUP BY 1, 2, 3, 4, 5, 6, 7 
	Having Sum(TraeArch.Menge) > 0 
) Daten
WHERE Abteil.ID = Daten.AbteilID 
	AND Traeger.ID = Daten.TraegerID 
	AND Abteil.KundenID = Kunden.ID 
	AND Daten.VsaID = Vsa.ID 
	AND Kunden.ID = KdBer.KundenID 
	AND KdBer.ID = (
		SELECT Min(ID)
		FROM KdBer
		WHERE KundenID = Kunden.ID 
			AND BereichID IN  (
				SELECT ID
				FROM Bereich
				WHERE BK = True
			)
	) 
	AND Artikel.ID = Daten.ArtikelID 
	AND Artikel.Status <> 'B' 
	AND LangBez.TableName = 'ARTIKEL' 
	AND LangBez.TableID = Artikel.ID 
	AND LangBez.LanguageID = -1
ORDER BY Abteil.Abteilung, TraegerName, Traeger.Traeger, Traeger.PersNr;

-- Anzahl Traeger -> Eigene Reportqueue

TRY
	DROP TABLE #TmpCountTraeger;
CATCH ALL END;

SELECT DISTINCT Traeger
INTO #TmpCountTraeger
FROM #TmpPersList
GROUP BY Traeger;

SELECT COUNT(*)
FROM #TmpCountTraeger;

-- Anzahl Teile -> Eigene Reportqueue

SELECT SUM(Menge)
FROM #TmpPersList;

-- Anzahl Teile je Artikel -> Eigene Reportqueue

SELECT ArtikelNr, Bez, SUM(Menge)
FROM #TmpPersList
GROUP BY ArtikelNr, Bez
ORDER BY ArtikelNr;