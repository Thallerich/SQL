DECLARE @vonDatum date = $STARTDATE$;
DECLARE @bisDatum date = $ENDDATE$;
DECLARE @vonWoche nchar(7) = (SELECT Week.Woche FROM Week WHERE @vonDatum BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @bisWoche nchar(7) = (SELECT Week.Woche FROM Week WHERE @bisDatum BETWEEN Week.VonDat AND Week.BisDat);

SELECT FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT') AS Monat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr AS [VSA-Nr],
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.Name1 AS [VSA-Adresszeile 1],
  Vsa.Name2 AS [VSA-Adresszeile 2],
  Vsa.GebaeudeBez AS Gebäude,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS [Größe],
  LsPo.EPreis AS Preis,
  SUM(LsPo.Menge) AS Menge,
  SUM(LsPo.Menge * LsPo.EPreis) AS [Summe netto]
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON LsPo.ArtGroeID = ArtGroe.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Abteil ON LsPo.AbteilID = Abteil.ID
WHERE Kunden.ID IN ($4$)
  AND LsKo.Datum BETWEEN @vonDatum AND @bisDatum
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
GROUP BY FORMAT(LsKo.Datum, N'yyyy-MM', N'de-AT'), Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Vsa.Name1, Vsa.Name2, Vsa.GebaeudeBez, Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, LsPo.EPreis

UNION ALL

SELECT AbtKdArW.Monat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr AS [VSA-Nr],
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.Name1 AS [VSA-Adresszeile 1],
  Vsa.Name2 AS [VSA-Adresszeile 2],
  Vsa.GebaeudeBez AS Gebäude,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  NULL AS [Größe],
  AbtKdArW.EPreis AS Preis,
  SUM(AbtKdArW.Menge) AS Menge,
  SUM(AbtKdArW.Menge * AbtKdArW.EPreis) AS [Summe netto]
FROM AbtKdArW
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AbtKdArW.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Abteil ON AbtKdArW.AbteilID = Abteil.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN Week ON Wochen.Woche = Week.Woche
WHERE Kunden.ID IN ($4$)
  AND Wochen.Woche BETWEEN @vonWoche AND @bisWoche
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
GROUP BY AbtKdArW.Monat, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Vsa.Name1, Vsa.Name2, Vsa.GebaeudeBez, Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, AbtKdArW.EPreis;