DECLARE @CurrentWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

CREATE TABLE #UmlaufArchiv (
  VsaID int,
  TraegerID int,
  KdArtiID int,
  ArtGroeID int,
  ArtikelID int,
  Umlauf int
);

INSERT INTO #UmlaufArchiv (VsaID, TraegerID, KdArtiID, ArtGroeID, ArtikelID, Umlauf)
SELECT VsaID, TraegerID, KdArtiID, ArtGroeID, ArtikelID, SUM(Umlauf) AS Umlauf
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
    AND Traeger.Emblem = 1  --Träger bekommt Emblem 

  UNION ALL

  SELECT Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
  JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
  LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
  WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
    AND KdArAppl.ArtiTypeID = 2 --Namenschild
    AND Traeger.NS = 1  --Träger bekommt Namenschild 
) AS x
GROUP BY VsaID, TraegerID, KdArtiID, ArtGroeID, ArtikelID;

SELECT VsaID, TraegerID, KdArtiID, ArtGroeID, ArtikelID, Umlauf
FROM #UmlaufArchiv;