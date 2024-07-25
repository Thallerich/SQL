DECLARE @CurrentWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'ARTIKEL'
),
Kundenartikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KDARTI'
)
SELECT Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], Kundenartikelstatus.StatusBez AS [Status Kundenartikel], Bereich.BereichBez AS Produktbereich, KdArti.BasisRestwert AS Basisrestwert_KdArti, Kunden.VertragWaeID AS Basisrestwert_KdArti_WaeID, Artikel.Basisrestwert AS [Basisrestwert Artikel (Vorschlag)], Artikel.EkPreis AS [EK-Preis], Umlaufmenge = (
  SELECT SUM(Umlauf) AS Umlauf
  FROM (
    SELECT VsaLeas.VsaID, - 1 AS TraegerID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaLeas.Menge) AS Umlauf
    FROM VsaLeas
    JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
    JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
    WHERE @CurrentWeek BETWEEN ISNULL(VsaLeas.Indienst, N'1980/01') AND ISNULL(VsaLeas.Ausdienst, N'2099/52')
    GROUP BY VsaLeas.VsaID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID

    UNION ALL

    SELECT VsaAnf.VsaID, - 1 AS TraegerID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaAnf.Bestand) AS Umlauf
    FROM VsaAnf
    JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
    WHERE VsaAnf.Bestand != 0
      AND VsaAnf.[Status] = N'A'
    GROUP BY VsaAnf.VsaID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1), KdArti.ArtikelID

    UNION ALL

    SELECT Strumpf.VsaID, - 1 AS TraegerID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(Strumpf.ID) AS Umlauf
    FROM Strumpf
    JOIN KdArti ON Strumpf.KdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
    WHERE Strumpf.[Status] != N'X'
      AND ISNULL(Strumpf.Indienst, N'1980/01') >= @CurrentWeek
      AND Strumpf.WegGrundID < 0
    GROUP BY Strumpf.VsaID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID
    
    UNION ALL

    SELECT Traeger.VsaID, TraeArti.TraegerID, TraeArti.KdArtiID, TraeArti.ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
    FROM TraeArti
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')

    UNION ALL

    SELECT Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
    FROM TraeArti
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
    JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
      AND KdArAppl.ArtiTypeID = 3  --Emblem

    UNION ALL

    SELECT Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
    FROM TraeArti
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
    JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
      AND KdArAppl.ArtiTypeID = 2 --Namenschild
  ) AS x
  WHERE x.KdArtiID = KdArti.ID
  GROUP BY x.KdArtiID
)
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
JOIN Kundenartikelstatus ON KdArti.[Status] = Kundenartikelstatus.[Status]
WHERE Artikel.EkPreis < 1
  AND (Bereich.Bereich != N'LW' AND Bereich.Bereich != N'PWS' AND Artikel.ArtikelNr NOT LIKE N'SW%')
  AND EXISTS (
    SELECT EinzHist.*
    FROM EinzTeil
    JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
    WHERE EinzHist.KdArtiID = KdArti.ID
      AND EinzHist.EinzHistTyp = 1
      AND EinzHist.PoolFkt = 0
      AND EinzTeil.AltenheimModus =  0
  );