DECLARE @CurrentWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @LagerID int = $2$;
DECLARE @von date = $STARTDATE$;
DECLARE @bis date = DATEADD(day, 1, $ENDDATE$);  -- add one day to include all stock transactions on the last day; date is implicitly converted to "dd.mm.yyyy 00:00:00", which would exclude all transactions on this date!

WITH BestandNeu AS (
  SELECT Bestand.ArtGroeID, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  WHERE Lagerart.LagerID = @LagerID
    AND Lagerart.Neuwertig = 1
  GROUP BY Bestand.ArtGroeID
),
BestandGebraucht AS (
  SELECT Bestand.ArtGroeID, SUM(Bestand.Bestand) AS Bestand
  FROM Bestand
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  WHERE Lagerart.LagerID = @LagerID
    AND Lagerart.Neuwertig = 0
  GROUP BY Bestand.ArtGroeID
),
LagerBewNeu AS (
  SELECT Bestand.ArtGroeID, SUM(LagerBew.Differenz) AS Lagerabgang
  FROM LagerBew
  JOIN Bestand ON LagerBew.BestandID = Bestand.ID
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  WHERE Lagerart.LagerID = @LagerID
    AND Lagerart.Neuwertig = 1
    AND LagerBew.Zeitpunkt BETWEEN @von AND @bis
    AND LagerBew.Differenz < 0
  GROUP BY Bestand.ArtGroeID
),
LagerBewGebraucht AS (
  SELECT Bestand.ArtGroeID, SUM(LagerBew.Differenz) AS Lagerabgang
  FROM LagerBew
  JOIN Bestand ON LagerBew.BestandID = Bestand.ID
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  WHERE Lagerart.LagerID = @LagerID
    AND Lagerart.Neuwertig = 0
    AND LagerBew.Zeitpunkt BETWEEN @von AND @bis
    AND LagerBew.Differenz < 0
  GROUP BY Bestand.ArtGroeID
),
Kundenstand AS (
  SELECT x.ArtGroeID, SUM(x.Umlauf) AS Umlauf
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
      AND Strumpf.Indienst >= @CurrentWeek
      AND Strumpf.WegGrundID < 0
    GROUP BY Strumpf.VsaID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID
    
    UNION ALL

    SELECT Traeger.VsaID, TraeArti.TraegerID, TraeArti.KdArtiID, TraeArti.ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
    FROM TraeArti
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
    WHERE @CurrentWeek BETWEEN Traeger.Indienst AND Traeger.Ausdienst

    UNION ALL

    SELECT Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
    FROM TraeArti
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
    JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
    WHERE @CurrentWeek BETWEEN Traeger.Indienst AND Traeger.Ausdienst
      AND KdArAppl.ArtiTypeID = 3  --Emblem
      AND Traeger.Emblem = 1  --Träger bekommt Emblem 

    UNION ALL

    SELECT Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
    FROM TraeArti
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
    JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
    WHERE @CurrentWeek BETWEEN Traeger.Indienst AND Traeger.Ausdienst
      AND KdArAppl.ArtiTypeID = 2 --Namenschild
      AND Traeger.NS = 1  --Träger bekommt Namenschild 
  ) AS x
  JOIN Vsa ON x.VsaID = Vsa.ID
  JOIN KdArti ON x.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  WHERE ((StandBer.LagerID = @LagerID AND StandBer.LokalLagerID < 0) OR StandBer.LokalLagerID = @LagerID)
  GROUP BY x.ArtGroeID
),
Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
)
SELECT Artikel.ArtikelNr AS Typ, Artikel.ArtikelNr + LEFT(ArtGroe.Groesse, IIF(CHARINDEX(N'/', ArtGroe.Groesse, 1) = 0, LEN(ArtGroe.Groesse), CHARINDEX(N'/', ArtGroe.Groesse, 1) - 1)) AS ArtNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.Gruppe AS Artgruppe, Artikelstatus.StatusBez AS [Status Artikel], SUM(ISNULL(BestandNeu.Bestand, 0)) AS Neu, SUM(ISNULL(BestandGebraucht.Bestand, 0)) AS Gebraucht, SUM(ISNULL(LagerBewNeu.Lagerabgang, 0)) AS [Lagerabgang Neu], SUM(ISNULL(LagerBewGebraucht.Lagerabgang, 0)) AS [Lagerabgang gebraucht], SUM(ISNULL(Kundenstand.Umlauf, 0)) AS [aktuell Kundenstand]
FROM ArtGroe
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
LEFT JOIN BestandNeu ON BestandNeu.ArtGroeID = ArtGroe.ID
LEFT JOIN BestandGebraucht ON BestandGebraucht.ArtGroeID = ArtGroe.ID
LEFT JOIN LagerBewNeu ON LagerBewNeu.ArtGroeID = ArtGroe.ID
LEFT JOIN LagerBewGebraucht ON LagerBewGebraucht.ArtGroeID = ArtGroe.ID
LEFT JOIN Kundenstand ON Kundenstand.ArtGroeID = ArtGroe.ID
WHERE Artikel.ID > 0
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelNr + LEFT(ArtGroe.Groesse, IIF(CHARINDEX(N'/', ArtGroe.Groesse, 1) = 0, LEN(ArtGroe.Groesse), CHARINDEX(N'/', ArtGroe.Groesse, 1) - 1)), Artikel.ArtikelBez, ArtGru.Gruppe, Artikelstatus.StatusBez
ORDER BY ArtNr;