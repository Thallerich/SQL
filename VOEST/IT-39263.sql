DROP TABLE IF EXISTS #TmpVOESTRechnung;

DECLARE @Kunden TABLE (
  KdNr int
);

DECLARE @Traeger TABLE (
  Nachname nvarchar(25) COLLATE Latin1_General_CS_AS,
  Vorname nvarchar(20) COLLATE Latin1_General_CS_AS
);

INSERT INTO @Kunden (KdNr) VALUES (272295), (10001223);

INSERT INTO @Traeger (Vorname, Nachname)
VALUES (N'Josef', N'Angermair'),
       (N'Johann', N'Probst'),
       (N'Siegfried', N'Fuchs'),
       (N'Ernst', N'Striegl'),
       (N'Pavel', N'Hrdina'),
       (N'Husnija', N'Dekanovic'),
       (N'Johann', N'Heiml'),
       (N'Helmut', N'Krottenthaler'),
       (N'Mohamet', N'Rreci');

WITH TraeAbtKdArW AS (
  SELECT TraeArti.TraegerID, TraeArti.KdArtiID, TraeArch.WochenID, SUM(TraeArch.Menge) AS Menge, TraeArch.Kostenlos, AbtKdArW.RechPoID, AbtKdArW.EPreis, SUM(TraeArch.Menge) * AbtKdArW.EPreis AS GPreis
  FROM TraeArch
  JOIN AbtKdArW ON TraeArch.AbtKdArWID = AbtKdArW.ID
  JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
  JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
  JOIN Abteil ON AbtKdArW.AbteilID = Abteil.ID
  JOIN RechPo ON AbtKdArW.RechPoID = RechPo.ID
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  JOIN Kunden ON RechKo.KundenID = Kunden.ID
  WHERE Kunden.KdNr IN (
    SELECT KdNr FROM @Kunden
  )
  GROUP BY TraeArti.TraegerID, TraeArti.KdArtiID, TraeArch.WochenID, TraeArch.Kostenlos, AbtKdArW.RechPoID, AbtKdArW.EPreis
)
SELECT Artikel.ID AS ArtikelID,
  Traeger.ID AS TraegerID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS VsaStichwort,
  Vsa.Bez AS VsaBezeichnung,
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Traeger.Traeger AS TraegerNr,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS ArtikelBez,
  KdArti.VariantBez AS Variante,
  MAX(TraeAbtKdArW.Menge) AS Maximalbestand,
  0 AS Waschzyklen,
  SUM(TraeAbtKdArW.GPreis) AS Mietkosten,
  CAST(0 AS money) AS Waschkosten,
  CAST(0 AS money) AS Gesamt,
  CAST(NULL AS nchar(7)) AS DatumErstausgabe,
  0 AS offenBestellt
INTO #TmpVOESTRechnung
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN TraeAbtKdArW ON TraeAbtKdArW.RechPoID = RechPo.ID
JOIN Traeger ON TraeAbtKdArW.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN @Traeger AS ATraeger ON ATraeger.Vorname = Traeger.Vorname AND ATraeger.Nachname = Traeger.Nachname
GROUP BY Artikel.ID,
  Traeger.ID,
  RechKo.RechNr,
  RechKo.RechDat,
  Kunden.KdNr,
  Kunden.SuchCode,
  Vsa.VsaNr,
  Vsa.SuchCode,
  Vsa.Bez,
  Vsa.GebaeudeBez,
  Vsa.Name2,
  Abteil.Abteilung,
  Abteil.Bez,
  Traeger.Traeger,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  KdArti.VariantBez;

MERGE INTO #TmpVOESTRechnung AS VOESTRechnung
USING (
  SELECT Teile.ArtikelID, Teile.TraegerID, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Vsa.GebaeudeBez AS Abteilung, Vsa.Name2 AS Bereich, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger AS TraegerNr, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS ArtikelBez, KdArti.Variante, LsPo.EPreis, COUNT(Scans.ID) AS Waschzyklen
  FROM Scans
  JOIN LsPo ON Scans.LsPoID = LsPo.ID
  JOIN Teile ON Scans.TeileID = Teile.ID
  JOIN Traeger ON Teile.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden oN Vsa.KundenID = Kunden.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  JOIN Abteil ON LsPo.AbteilID = Abteil.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN @Traeger AS ATraeger ON ATraeger.Vorname = Traeger.Vorname AND ATraeger.Nachname = Traeger.Nachname
  WHERE RechKo.RechNr IN (SELECT RechNr FROM #TmpVOESTRechnung)
  GROUP BY Teile.ArtikelID, Teile.TraegerID, RechKo.RechNr, RechKo.RechDat, Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Vsa.GebaeudeBez, Vsa.Name2, Abteil.Abteilung, Abteil.Bez, Traeger.Traeger, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, LsPo.EPreis
) AS Bearbeitung
ON Bearbeitung.ArtikelID = VOESTRechnung.ArtikelID AND Bearbeitung.TraegerID = VOESTRechnung.TraegerID AND Bearbeitung.Variante = VOESTRechnung.Variante
WHEN MATCHED THEN
  UPDATE SET Waschkosten = Bearbeitung.EPreis * Bearbeitung.Waschzyklen, Waschzyklen = Bearbeitung.Waschzyklen
WHEN NOT MATCHED THEN
  INSERT (ArtikelID, TraegerID, RechNr, RechDat, KdNr, Kunde, VsaNr, VsaStichwort, VsaBezeichnung, Abteilung, Bereich, Kostenstelle, Kostenstellenbezeichnung, TraegerNr, PersNr, Nachname, Vorname, ArtikelNr, ArtikelBez, Variante, Mietkosten, Waschkosten, Waschzyklen, offenBestellt)
  VALUES (Bearbeitung.ArtikelID, Bearbeitung.TraegerID, Bearbeitung.RechNr, Bearbeitung.RechDat, Bearbeitung.KdNr, Bearbeitung.Kunde, Bearbeitung.VsaNr, Bearbeitung.VsaStichwort, Bearbeitung.VsaBezeichnung, Bearbeitung.Abteilung, Bearbeitung.Bereich, Bearbeitung.Kostenstelle, Bearbeitung.Kostenstellenbezeichnung, Bearbeitung.TraegerNr, Bearbeitung.PersNr, Bearbeitung.Nachname, Bearbeitung.Vorname, Bearbeitung.ArtikelNr, Bearbeitung.ArtikelBez, Bearbeitung.Variante, 0, Bearbeitung.EPreis * Bearbeitung.Waschzyklen, Bearbeitung.Waschzyklen, 0);

UPDATE #TmpVOESTRechnung SET Gesamt = Waschkosten + Mietkosten;

/* UPDATE VOESTRechnung SET offenBestellt = x.ob
FROM #TmpVOESTRechnung AS VOESTRechnung
JOIN (
  SELECT Teile.TraegerID, Teile.ArtikelID, COUNT(Teile.ID) AS ob
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  WHERE Vsa.KundenID = (
    SELECT RechKo.KundenID
    FROM RechKo
    WHERE RechKo.ID = @RechKoID
  )
    AND Teile.Status BETWEEN N'E' AND N'N'
  GROUP BY Teile.TraegerID, Teile.ArtikelID
) AS x ON x.TraegerID = VOESTRechnung.TraegerID AND x.ArtikelID = VOESTRechnung.ArtikelID; */

SELECT RechNr, RechDat AS Rechnungsdatum, KdNr, Kunde, VsaNr, VsaBezeichnung AS [Vsa-Bezeichnung], Abteilung, Bereich, Kostenstelle, Kostenstellenbezeichnung, TraegerNr AS TrägerNr, PersNr AS Personalnummer, Nachname, Vorname, ArtikelNr, ArtikelBez AS Artikelbezeichnung, Variante AS Verrechnungsart, Maximalbestand, Waschzyklen, Mietkosten, Waschkosten, Gesamt AS Gesamtkosten --, offenBestellt AS [offene bestelle Wäscheteile]
FROM #TmpVOESTRechnung
ORDER BY Rechnungsdatum, TrägerNr, KdNr;