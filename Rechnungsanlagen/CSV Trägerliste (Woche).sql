DROP TABLE IF EXISTS #TmpTraeArch;

DECLARE @MasterWochenID int = (SELECT Rechko.MasterWochenID FROM RechKo WHERE RechKo.ID = $RECHKOID$);
DECLARE @RKoBisDatum date = (SELECT RechKo.BisDatum FROM RechKo WHERE RechKo.ID = $RECHKOID$);

IF @MasterWochenID <= 0
BEGIN
  SET @MasterWochenID = (SELECT Wochen.ID FROM Wochen WHERE Wochen.Woche = (SELECT Week.Woche FROM Week WHERE @RKoBisDatum BETWEEN Week.VonDat AND Week.BisDat))
END;

SELECT TraeArch.*
INTO #TmpTraeArch
FROM TraeArch
WHERE TraeArch.WochenID = @MasterWochenID;

SELECT Wochen.Woche, Traeger.Nachname, Traeger.Vorname, TraeArch.Menge, ArtGroe.Groesse, (
  SELECT TOP 1 SchrankNr
  FROM Schrank,TraeFach
  WHERE TraeFach.SchrankID=Schrank.ID
    AND TraeFach.TraegerID=Traeger.ID
) AS Schrank, (
  SELECT TOP 1 Fach
  FROM TraeFach
  WHERE Traeger.ID=TraegerID
) AS Fach, (
  SELECT VariantBez
  FROM KdArti
  WHERE ID=Traeger.BerufsgrKdArtiID
) AS BG, Artikel.ArtikelNr, Artikel.ArtikelBez AS ArtikelBez,
Kunden.Name1 as Kunde, VSA.Bez as VSA, Abteil.Bez as KSt, KdArti.Variante, KdArti.VariantBez
FROM #TmpTraeArch AS TraeArch, Wochen, Kunden, VSA, Abteil, TraeArti, ArtGroe, KdArti, Artikel, Traeger, Rechko
WHERE Traeger.ID=TraeArti.TraegerID
  AND KdArti.ArtikelID=Artikel.ID
  AND KdArti.ID=TraeArti.KdArtiID
  AND ArtGroe.ID=TraeArti.ArtGroeID
  AND TraeArti.ID=TraeArch.TraeArtiID
  AND Abteil.ID=TraeArch.AbteilID
  AND VSA.ID=TraeArch.VSAID
  AND Kunden.ID=TraeArch.KundenID
  AND Kunden.ID=Rechko.KundenID
  AND Wochen.ID=TraeArch.WochenID
  AND Rechko.ID=$RECHKOID$
ORDER BY VSA, Traeger.Nachname, Traeger.Vorname;