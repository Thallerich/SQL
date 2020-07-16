-- ################################################################################################################################
-- ## Pipeline: Kunden
-- ################################################################################################################################

SELECT TOP 1 KdNr, IIF ($2$ = $TRUE$, VSA.Name1, Kunden.Name1) AS Name1, IIF ($2$ = $TRUE$, Vsa.Name2, Kunden.Name2) AS Name2, IIF ($2$ = $TRUE$, Vsa.Strasse, Kunden.Strasse) AS Strasse, IIF ($2$ = $TRUE$, Vsa.PLZ, Kunden.PLZ) AS PLZ, IIF ($2$ = $TRUE$, Vsa.Ort, Kunden.Ort) AS Ort, IIF ($2$ = $TRUE$, Vsa.Land, Kunden.Land) AS Land
FROM Kunden, Vsa
WHERE Kunden.ID = $ID$
  AND Vsa.KundenID = Kunden.ID;

-- ################################################################################################################################
-- ## Pipeline: Mengenzusammenstellung
-- ################################################################################################################################

SELECT Vsa.ID as VsaID, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, KdArti.Variante, KdArti.VariantBez, COUNT(DISTINCT Traeger.ID) AS Traeger, SUM(TraeArch.Menge) AS Menge
FROM TraeArti, TraeArch, Wochen, Kunden, Traeger, KdArti, Artikel, Vsa
WHERE Traeger.VsaID = Vsa.ID
  AND Traeger.ID = TraeArti.TraegerID
  AND TraeArti.ID = TraeArch.TraeArtiID
  AND TraeArch.WochenID = Wochen.ID
  AND TraeArch.KundenID = Kunden.ID
  AND KdArti.ID = TraeArti.KdArtiID
  AND Artikel.ID = KdArti.ArtikelID
  AND Wochen.Woche = $1$
  AND Kunden.ID = $ID$
GROUP BY Vsa.ID, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.Variante, KdArti.VariantBez
ORDER BY Vsa.ID, Artikel.ArtikelNr, KdArti.Variante;

-- ################################################################################################################################
-- ## Pipeline: Traeger
-- ################################################################################################################################

DROP TABLE IF EXISTS #TempPersonalliste;

SELECT Vsa.ID AS VsaID, Traeger.ID AS TraegerID, Wochen.Woche, Traeger.Traeger AS TrägerNr, Traeger.PersNr, RTRIM(Traeger.Nachname) AS Nachname, RTRIM(Traeger.Vorname) AS Vorname, TraeArch.Menge, ArtGroe.Groesse, (
	SELECT TOP 1 SchrankNr
	FROM Schrank, TraeFach
	WHERE TraeFach.SchrankID = Schrank.ID
		AND TraeFach.TraegerID = Traeger.ID
) AS Schrank, (
	SELECT TOP 1 Fach
	FROM TraeFach
	WHERE Traeger.ID = TraegerID
) AS Fach, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, KdArti.Variante, KdArti.VariantBez, Kunden.Name1 AS Kunde, RTRIM(VSA.Bez) + ' ('+ RTRIM(VSA.SuchCode) + ')' AS Vsa, Abteil.Bez AS KsSt
INTO #TempPersonalliste
FROM TraeArch, Wochen, Kunden, VSA, Abteil, TraeArti, ArtGroe, KdArti, Artikel, Traeger
WHERE Traeger.ID = TraeArti.TraegerID
	AND KdArti.ArtikelID = Artikel.ID
	AND KdArti.ID = TraeArti.KdArtiID
	AND ArtGroe.ID = TraeArti.ArtGroeID
	AND TraeArti.ID = TraeArch.TraeArtiID
	AND Abteil.ID = TraeArch.AbteilID
	AND VSA.ID = TraeArch.VSAID
	AND Kunden.ID = TraeArch.KundenID
	AND Wochen.ID = TraeArch.WochenID
	AND Kunden.ID = $ID$
	AND Wochen.Woche = $1$
ORDER BY Vsa.ID, Nachname, Vorname;

DROP TABLE IF EXISTS #TempAnzTraeger;

SELECT COUNT(DISTINCT TraegerID) AS AnzTraeger, VsaID
INTO #TempAnzTraeger
FROM #TempPersonalliste
GROUP BY VsaID;

SELECT AnzT.AnzTraeger, PL.*
FROM #TempPersonalliste PL, #TempAnzTraeger AnzT
WHERE PL.VsaID = AnzT.VsaID;