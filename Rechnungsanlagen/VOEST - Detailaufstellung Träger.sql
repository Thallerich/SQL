DROP TABLE IF EXISTS #TmpVOESTRechnung;
GO

DECLARE @RechKoID int = (SELECT ID FROM RechKo WHERE RechNr = 30034988);

WITH TraeAbtKdArW AS (
  SELECT TraeArti.TraegerID, TraeArti.KdArtiID, TraeArch.WochenID, SUM(TraeArch.Menge) AS Menge, AbtKdArW.RechPoID, AbtKdArW.EPreis
  FROM TraeArch
  JOIN AbtKdArW ON TraeArch.AbtKdArWID = AbtKdArW.ID
  JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
  WHERE AbtKdArW.RechPoID IN (
    SELECT RechPo.ID
    FROM RechPo
    WHERE RechPo.RechKoID = @RechKoID
  )
  GROUP BY TraeArti.TraegerID, TraeArti.KdArtiID, TraeArch.WochenID, AbtKdArW.RechPoID, AbtKdArW.EPreis
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
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Traeger.Traeger AS TraegerNr,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  MAX(TraeAbtKdArW.Menge) AS Maximalbestand,
  0 AS Waschzyklen,
  SUM(TraeAbtKdArW.Menge * TraeAbtKdArW.EPreis) AS Mietkosten,
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
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN KdArti ON TraeAbtKdArW.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE RechKo.ID = @RechKoID
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
  Abteil.Abteilung,
  Abteil.Bez,
  Traeger.Traeger,
  Traeger.PersNr,
  Traeger.Nachname,
  Traeger.Vorname,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez,
  KdArti.LeasingPreis,
  KdArti.WaschPreis;

UPDATE VOESTRechnung SET Waschkosten = x.EPreis * x.Waschzyklen, Waschzyklen = x.Waschzyklen
FROM #TmpVOESTRechnung AS VOESTRechnung
JOIN (
  SELECT Teile.ArtikelID, Teile.TraegerID, LsPo.EPreis, COUNT(Scans.ID) AS Waschzyklen
  FROM Scans
  JOIN LsPo ON Scans.LsPoID = LsPo.ID
  JOIN Teile ON Scans.TeileID = Teile.ID
  WHERE LsPo.RechPoID IN (
    SELECT RechPo.ID
    FROM RechPo
    WHERE RechPo.RechKoID = @RechKoID
  )
  GROUP BY Teile.ArtikelID, Teile.TraegerID, LsPo.EPreis
) AS x ON x.ArtikelID = VOESTRechnung.ArtikelID AND x.TraegerID = VOESTRechnung.TraegerID;

UPDATE #TmpVOESTRechnung SET Gesamt = Waschkosten + Mietkosten;

UPDATE VOESTRechnung SET DatumErstausgabe = x.MIndienst
FROM #TmpVOESTRechnung AS VOESTRechnung
JOIN (
  SELECT Teile.TraegerID, Teile.ArtikelID, MIN(Teile.Indienst) AS MInDienst
  FROM Teile
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  WHERE Vsa.KundenID = (
    SELECT RechKo.KundenID
    FROM RechKo
    WHERE RechKo.ID = @RechKoID
  )
    AND Teile.Status BETWEEN N'Q' AND N'W'
    AND Teile.Einzug IS NULL
  GROUP BY Teile.TraegerID, Teile.ArtikelID
) AS x ON x.TraegerID = VOESTRechnung.TraegerID AND x.ArtikelID = VOESTRechnung.ArtikelID;

UPDATE VOESTRechnung SET offenBestellt = x.ob
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
) AS x ON x.TraegerID = VOESTRechnung.TraegerID AND x.ArtikelID = VOESTRechnung.ArtikelID;

SELECT RechNr, RechDat AS Rechnungsdatum, KdNr, Kunde, VsaNr, VsaBezeichnung AS [Vsa-Bezeichnung], Abteilung, Kostenstelle, Kostenstellenbezeichnung, TraegerNr AS TrägerNr, PersNr AS Personalnummer, Nachname, Vorname, ArtikelNr, ArtikelBez AS Artikelbezeichnung, Maximalbestand, Waschzyklen, Mietkosten, Waschkosten, Gesamt AS Gesamtkosten, DatumErstausgabe AS [Erste Ausgabe-Woche], offenBestellt AS [offene bestelle Wäscheteile] FROM #TmpVOESTRechnung;

GO