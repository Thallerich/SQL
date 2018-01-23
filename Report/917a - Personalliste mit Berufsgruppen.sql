IF object_id(N'tempdb..#TmpTraeArch') IS NOT NULL
BEGIN
  DROP TABLE #TmpTraeArch;
END

SELECT TraeArch.KundenID, TraeArch.TraeArtiID, TraeArch.Menge
INTO #TmpTraeArch
FROM TraeArch
WHERE TraeArch.WochenID = (SELECT Wochen.ID FROM Wochen WHERE Wochen.Woche = $1$)  --$1$
  AND TraeArch.KundenID = $ID$; --$ID$

IF object_ID(N'tempdb..#TmpFinal') IS NOT NULL
BEGIN
  DROP TABLE #TmpFinal;
END

SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Abteil.Abteilung AS KsSt, Abteil.Bez AS KsStBez, Traeger.Traeger, Traeger.PersNr, Status.StatusBez AS Traegerstatus, Traeger.ID AS TraegerID, Traeger.Nachname, Traeger.Vorname, Traeger.Titel, CONVERT(nvarchar(60), NULL) AS Berufsgruppe, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse, Traeger.SchrankInfo, TraeArch.Menge
INTO #TmpFinal
FROM TraeArti, Traeger, Kunden, KdArti, Artikel, ArtGroe, Abteil, (SELECT Status.Status, Status.StatusBez$LAN$ AS StatusBez FROM Status WHERE Status.Tabelle = 'TRAEGER') AS Status, #TmpTraeArch AS TraeArch
WHERE TraeArch.TraeArtiID = TraeArti.ID
  AND TraeArti.TraegerID = Traeger.ID
  AND TraeArch.KundenID = Kunden.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND Traeger.Status = Status.Status
  AND Traeger.AbteilID = Abteil.ID
  AND Artikel.ArtikelNr <> 'BERUFE'
ORDER BY KundenID, KsSt, Traeger.Nachname, TraegerID;

UPDATE Final SET Final.Berufsgruppe = Berufe.Berufsgruppe
FROM #TmpFinal AS Final, (
  SELECT Traeger.ID AS TraegerID, KdArti.VariantBez AS Berufsgruppe
  FROM #TmpTraeArch AS TraeArch, TraeArti, Traeger, KdArti, Artikel
  WHERE TraeArch.TraeArtiID = TraeArti.ID
    AND TraeArti.TraegerID = Traeger.ID
    AND TraeArti.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND Artikel.ArtikelNr = 'BERUFE'
) AS Berufe
WHERE Berufe.TraegerID = Final.TraegerID;

SELECT * FROM #TmpFinal;