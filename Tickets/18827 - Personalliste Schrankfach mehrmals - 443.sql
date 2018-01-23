TRY
  DROP TABLE #TempPersonalliste;
  DROP TABLE #TempAnzTraeger;
CATCH ALL END;

SELECT VSA.ID AS VSAID, Traeger.ID AS TraegerID, Wochen.Woche, Trim(Traeger.Nachname) AS Nachname, Traeger.Vorname AS Vorname, TraeArch.Menge, ArtGroe.Groesse, TraeFach.Fach AS Fach, Schrank.SchrankNr AS Schrank, ViewArtikel.ArtikelNr,ViewArtikel.ArtikelBez, Kunden.Name1 AS Kunde, TRIM(VSA.Bez) + ' ('+ TRIM(VSA.SuchCode) + ')' AS VSA, Abteil.Bez AS KSt
INTO #TempPersonalliste
FROM TraeArch, Wochen, Kunden, VSA, Abteil, TraeArti, ArtGroe, KdArti, ViewArtikel, Traeger, Schrank, TraeFach
WHERE Traeger.ID = TraeArti.TraegerID 
	AND KdArti.ArtikelID=ViewArtikel.ID 
	AND KdArti.ID=TraeArti.KdArtiID 
	AND ArtGroe.ID=TraeArti.ArtGroeID 
	AND TraeArti.ID=TraeArch.TraeArtiID 
	AND Abteil.ID=TraeArch.AbteilID 
	AND VSA.ID=TraeArch.VSAID 
	AND Kunden.ID=TraeArch.KundenID 
	AND Wochen.ID=TraeArch.WochenID 
	AND TraeFach.TraegerID = Traeger.ID
	AND TraeFach.SchrankID = Schrank.ID
	AND Kunden.ID=$ID$ 
	AND Wochen.Woche=$1$ 
	AND ViewArtikel.LanguageID=$LANGUAGE$
ORDER BY VSA.ID, Nachname, Vorname;

SELECT COUNT(TraegerID) AS AnzTraeger, VSAID 
INTO #TempAnzTraeger 
FROM (
	SELECT DISTINCT TraegerID, VSAID 
	FROM #TempPersonalliste
) a 
GROUP BY 2;

SELECT AnzT.AnzTraeger, PL.* 
FROM #TempPersonalliste PL, #TempAnzTraeger AnzT 
WHERE PL.VSAID = AnzT.VSAID;