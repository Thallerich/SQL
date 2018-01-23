DROP TABLE IF EXISTS #TmpOpSetGewicht;
DROP TABLE IF EXISTS #TmpLieferMenge;

SELECT OPSets.ArtikelID, SetArtikel.ArtikelNr, SetArtikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SetArtikel._SteriArtID, ROUND(SUM(OPSets.Menge * Artikel.StueckGewicht), 3) AS SetGewicht, SetArtikel.Laenge AS SetLänge, SetArtikel.Breite AS SetBreite, SetArtikel.Hoehe AS SetHöhe
INTO #TmpOPSetGewicht
FROM OPSets, Artikel, Artikel SetArtikel
WHERE OPSets.Artikel1ID = Artikel.ID
  AND OPSets.ArtikelID = SetArtikel.ID
  AND SetArtikel._SteriArtID IN (
    SELECT _Auswahl.ID
    FROM _Auswahl
    WHERE _Auswahl._TableField = N'Artikel._SteriArtID'
  )
GROUP BY OPSets.ArtikelID, SetArtikel.ArtikelNr, SetArtikel.ArtikelBez$LAN$, SetArtikel._SteriArtID, SetArtikel.Laenge, SetArtikel.Breite, SetArtikel.Hoehe;

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, OPSetGewicht.SetGewicht, OPSetGewicht.SetLänge, OPSetGewicht.SetBreite, OPSetGewicht.SetHöhe, Artikel._SteriArtID, SUM(LsPo.Menge) AS Menge, Artikel.ID AS ArtikelID, LsPo.ProduktionID
INTO #TmpLieferMenge
FROM LsPo, LsKo, KdArti, Artikel, [#TmpOPSetGewicht] OPSetGewicht
WHERE LsPo.LsKoID = LsKo.ID
  AND LsPo.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND OPSetGewicht.ArtikelID = Artikel.ID
  AND Artikel._SteriArtID > 0
  AND LsKo.Datum BETWEEN $1$ AND $2$
  AND LsKo.VsaID NOT IN (
    SELECT StandBer.AnfLagerVSAID
    FROM StandBer
    WHERE StandBer.AnfLagerVSAID > 0
  )
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, OPSetGewicht.SetGewicht, OPSetGewicht.SetBreite, OPSetGewicht.SetLänge, OPSetGewicht.SetHöhe, Artikel._SteriArtID, Artikel.ID, LsPo.ProduktionID;

SELECT Standort.Bez AS Expedition, LM.ArtikelNr, LM.Artikelbezeichnung, _Auswahl._Bez AS Sterilisationsart, LM.Menge AS Liefermenge, LM.SetLänge, LM.SetBreite, LM.SetHöhe, ROUND((LM.SetLänge * LM.SetBreite * LM.SetHöhe) / (60 * 30 * 30), 3) AS STE, ROUND((LM.SetLänge * LM.SetBreite * LM.SetHöhe) / (60 * 30 * 30), 3) * LM.Menge AS GesamtSTE, LM.SetGewicht AS [Stueckgewicht (kg)], LM.Menge * LM.SetGewicht AS [Gesamtgewicht (kg)]
FROM [#TmpLieferMenge] LM, _Auswahl, Standort
WHERE LM._SteriArtID = _Auswahl.ID
  AND _Auswahl._TableField = N'Artikel._SteriArtID'
  AND LM.ProduktionID = Standort.ID
  AND LM._SteriArtID <> 6 --Kombi-Set im folgenden aufteilen auf Inhaltsset

UNION 

SELECT Standort.Bez AS Expedition, OPSetGewicht.ArtikelNr, OPSetGewicht.Artikelbezeichnung AS Artikelbezeichnung, _Auswahl._Bez AS Sterilisationsart, LM.Menge * OPSets.Menge AS Liefermenge, OPSetGewicht.SetLänge, OPSetGewicht.SetBreite, OPSetGewicht.SetHöhe, ROUND((OPSetGewicht.SetLänge * OPSetGewicht.SetBreite * OPSetGewicht.SetHöhe) / (60 * 30 * 30), 3) AS STE, ROUND((OPSetGewicht.SetLänge * OPSetGewicht.SetBreite * OPSetGewicht.SetHöhe) / (60 * 30 * 30), 3) * (LM.Menge * OPSets.Menge) AS GesamtSTE, OPSetGewicht.SetGewicht AS [Stueckgewicht (kg)], LM.Menge * OPSets.Menge * OPSetGewicht.SetGewicht AS [Gesamtgewicht (kg)]
FROM [#TmpLieferMenge] LM, OPSets, [#TmpOPSetGewicht] OPSetGewicht, _Auswahl, Standort
WHERE LM.ArtikelID = OPSets.ArtikelID
  AND OPSets.Artikel1ID = OPSetGewicht.ArtikelID
  AND OPSetGewicht._SteriArtID = _Auswahl.ID
  AND _Auswahl._TableField = N'Artikel._SteriArtID'
  AND LM.ProduktionID = Standort.ID
  AND LM._SteriArtID = 6 --nur Kombi-Sets
;