SELECT Kunden.FirmaID, Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.UStIdNr, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Vsa.Strasse, Vsa.PLZ, Touren.Tour, Touren.ExpeditionID, LsKo.Folge, Mitarbei.Name AS Fahrer, LsKo.ID AS LsKoID, LsKo.LsNr, LsKo.Datum AS Lieferdatum, Week.Woche AS Lieferwoche, LsKo.UnterschriftName, LsKo.UnterschriftTime, LsKo.UnterschriftJpg,  LsKo.ScannedBarcode, CAST(IIF(LsKo.UnterschriftName IS NOT NULL, 1, 0) AS bit) AS PrintUnterschrift, LsPo.AbteilID, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, ArtGroe.Groesse, LsPo.Menge AS Liefermenge, LsPo.Memo, LsKo.Memo AS LsKoMemo
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON LsPo.ArtGroeID = ArtGroe.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
JOIN Week ON LsKo.Datum BETWEEN Week.VonDat AND Week.BisDat
JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
JOIN Touren ON Fahrt.TourenID = Touren.ID
JOIN Mitarbei ON Fahrt.MitarbeiID = Mitarbei.ID
JOIN Abteil ON LsPo.AbteilID = Abteil.ID
WHERE NOT EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.RechPoID > 0
  )
  AND Kunden.ID = $ID$
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
ORDER BY Lieferdatum, LsKoID, ArtikelNr, GroePo.Folge;