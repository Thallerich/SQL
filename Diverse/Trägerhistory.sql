TRY
	DROP TABLE #TmpEinAusDienst;
	DROP TABLE #TmpMassAenderung;
	DROP TABLE #TmpTraeArch;
CATCH ALL END;

SELECT Traeger.ID, Traeger.Traeger, TRIM(IIF(Traeger.Titel IS NULL,'',Traeger.Titel))+' '+TRIM(IIF(Traeger.Vorname IS NULL,'',Traeger.Vorname))+' '+TRIM(IIF(Traeger.Nachname IS NULL,'',Traeger.Nachname)) AS Name, Traeger.Indienst, Traeger.Ausdienst, Kunden.KdNr, TRIM(IIF(Kunden.Name1 IS NULL,'',Kunden.Name1))+' '+TRIM(IIF(Kunden.Name2 IS NULL,'',Kunden.Name2))+' '+TRIM(IIF(Kunden.Name3 IS NULL,'',Kunden.Name3)) AS Kunde
INTO #TmpEinAusDienst
FROM Traeger, Vsa, Kunden
WHERE ((Traeger.Indienst >= CONVERT(YEAR($2$),SQL_VARCHAR)+'/'+CONVERT(WEEK($2$),SQL_VARCHAR) AND Traeger.Indienst <= CONVERT(YEAR($3$),SQL_VARCHAR)+'/'+CONVERT(WEEK($3$),SQL_VARCHAR))
	OR (Traeger.Ausdienst >= CONVERT(YEAR($2$),SQL_VARCHAR)+'/'+CONVERT(WEEK($2$),SQL_VARCHAR) AND Traeger.Ausdienst <= CONVERT(YEAR($3$),SQL_VARCHAR)+'/'+CONVERT(WEEK($3$),SQL_VARCHAR)))
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.ID = $1$;

SELECT Traeger.ID, Traeger.Traeger, TRIM(IIF(Traeger.Titel IS NULL,'',Traeger.Titel))+' '+TRIM(IIF(Traeger.Vorname IS NULL,'',Traeger.Vorname))+' '+TRIM(IIF(Traeger.Nachname IS NULL,'',Traeger.Nachname)) AS Name, Langbez.Bez AS Aenderungsart, TraeMass.Mass, Kunden.KdNr, TRIM(IIF(Kunden.Name1 IS NULL,'',Kunden.Name1))+' '+TRIM(IIF(Kunden.Name2 IS NULL,'',Kunden.Name2))+' '+TRIM(IIF(Kunden.Name3 IS NULL,'',Kunden.Name3)) AS Kunde
INTO #TmpMassAenderung
FROM TraeMass, MassOrt, Langbez, TraeArti, Traeger, Vsa, Kunden
WHERE CONVERT(TraeMass.Anlage_,SQL_DATE) BETWEEN $2$ AND $3$
	AND TraeMass.MassOrtID = MassOrt.ID
	AND MassOrt.ID = Langbez.TableID
	AND Langbez.TableName = 'MASSORT'
	AND TraeMass.TraeArtiID = TraeArti.ID
	AND TraeArti.TraegerID = Traeger.ID
	AND TraeArti.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.ID = $1$;

SELECT Traeger.ID, Traeger.Traeger, TRIM(IIF(Traeger.Titel IS NULL,'',Traeger.Titel))+' '+TRIM(IIF(Traeger.Vorname IS NULL,'',Traeger.Vorname))+' '+TRIM(IIF(Traeger.Nachname IS NULL,'',Traeger.Nachname)) AS Name, Wochen.Woche, Abteil.Abteilung, Abteil.Bez AS Abteilungsname, BGrp.VariantBez Berufsgruppe, TraeArch.Menge, Artikel.ArtikelNr, Artikel.ArtikelBez, Kunden.KdNr, TRIM(IIF(Kunden.Name1 IS NULL,'',Kunden.Name1))+' '+TRIM(IIF(Kunden.Name2 IS NULL,'',Kunden.Name2))+' '+TRIM(IIF(Kunden.Name3 IS NULL,'',Kunden.Name3)) AS Kunde
INTO #TmpTraeArch
FROM TraeArch, TraeArti, Wochen, Abteil, Traeger, KdArti, ViewArtikel Artikel, KdArti BGrp, ViewArtikel BGrpArt, Kunden
WHERE TraeArch.TraeArtiID = TraeArti.ID 
	AND TraeArch.KundenID = Kunden.ID
	AND Kunden.ID = $1$
	AND Wochen.Woche >= CONVERT(YEAR($2$),SQL_VARCHAR)+'/'+CONVERT(WEEK($2$),SQL_VARCHAR)
	AND Wochen.Woche <= CONVERT(YEAR($3$),SQL_VARCHAR)+'/'+CONVERT(WEEK($3$),SQL_VARCHAR)
	AND TraeArch.WochenID = Wochen.ID 
	AND Abteil.ID = TraeArch.AbteilID 
	AND TraeArti.TraegerID = Traeger.ID 
	AND TraeArti.KdArtiID = KdArti.ID 
	AND KdArti.ArtikelID = Artikel.ID 
	AND Artikel.LanguageID = -1 
	AND Traeger.BerufsgrKdArtiID = BGrp.ID 
	AND BGrpArt.ID = BGrp.ArtikelID 
	AND BGrpArt.LanguageID = -1;
	
SELECT IIF(IIF(tead.KdNr IS NULL,tta.KdNr,tead.KdNr) IS NULL,tma.KdNr,IIF(tead.KdNr IS NULL,tta.KdNr,tead.KdNr)) AS KdNr, IIF(IIF(tead.Kunde IS NULL, tta.Kunde,tead.Kunde) IS NULL, tma.Kunde, IIF(tead.Kunde IS NULL, tta.Kunde,tead.Kunde)) AS Kunde, tta.Traeger, tta.Name, tead.Indienst, tead.Ausdienst, tta.Woche, tta.Abteilung, tta.Abteilungsname, tta.Berufsgruppe, tta.Menge, tta.ArtikelNr, tta.ArtikelBez, tma.Aenderungsart, tma.Mass
FROM #TmpTraeArch tta
FULL OUTER JOIN #TmpMassAenderung tma
	ON tma.ID = tta.ID
FULL OUTER JOIN #TmpEinAusDienst tead
	ON tead.ID = tta.ID;