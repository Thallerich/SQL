DECLARE @currentweek nchar(7) = (SELECT Week.Woche FROM [Week] WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT EinzHist.Barcode,
  Teilestatus.StatusBez AS [aktueller Status],
  Vsa.VsaNr AS [Vsa-Nr],
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [Vsa-Bezeichnung],
  Vsa.GebaeudeBez AS Abteilung,
  Vsa.Name2 AS Bereich,
  Traeger.Traeger AS [Träger-Nr],
  Traeger.Vorname,
  Traeger.Nachname,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  EinzHist.IndienstDat AS [Datum Indienststellung aktueller Träger],
  EinzHist.AbmeldDat AS [Datum Abmeldung],
  EinzHist.AusdienstDat AS [Datum Außerdienststellung],
  DATEDIFF(day, EinzHist.IndienstDat, ISNULL(EinzHist.AusdienstDat, CAST(GETDATE() AS date))) AS [Tage im Einsatz],
  EinzHist.RuecklaufK AS [Waschzyklen aktueller Träger],
  EinzTeil.RuecklaufG AS [Waschzyklen gesamt],
  [an Wäscherei retourniert] = CAST(
      CASE
        WHEN EinzHist.[Status] = N'U' AND EinzHist.Einzug IS NOT NULL THEN 1
        WHEN EinzHist.[Status] = N'U' AND EinzHist.Einzug IS  NULL THEN 0
        WHEN EinzHist.[Status] = N'W' AND EinzHist.Einzug IS NOT NULL THEN 1
        WHEN EinzHist.[Status] = N'W' AND EinzHist.Einzug IS  NULL THEN 0
        ELSE NULL
      END
    AS bit),
  [Teil in Verrechnung] = CAST(
    CASE
      WHEN EinzHist.Kostenlos = 0 
        AND Traeger.[Status] NOT IN (N'K', N'P')
        AND ISNULL(EinzHist.Indienst, N'2099/52') <= @currentweek AND ISNULL(EinzHist.Ausdienst, N'2099/52') > @currentweek
        AND Vsa.[Status] = N'A'
        AND EXISTS (SELECT ID FROM JahrLief WHERE JahrLief.TableID = Vsa.ID AND JahrLief.TableName = N'VSA' AND JahrLief.Jahr = DATEPART(year, CAST(GETDATE() AS date)) AND SUBSTRING(JahrLief.Lieferwochen, DATEPART(week, CAST(GETDATE() AS date)), 1) IN (N'X', N'W', N'B', N'S', N'N'))
        AND EXISTS (SELECT ID FROM VsaBer WHERE VsaBer.VsaID = Vsa.ID AND VsaBer.[Status] = N'A' AND VsaBer.ErstFakLeas <= @currentweek AND VsaBer.KdBerID = KdArti.KdBerID)
      THEN 1
      ELSE 0
    END
  AS bit),
  [Anzahl Reparaturen] = (
    SELECT CAST(SUM(TeilSoFa.Menge) AS int)
    FROM TeilSoFa
    JOIN Artikel ON TeilSoFa.ArtikelID = Artikel.ID
    WHERE TeilSoFa.EinzHistID = EinzHist.ID
      AND Artikel.ArtiTypeID = 5
  ),
  [erfasste Reparaturen] = STUFF((
    SELECT N', ' + Artikel.ArtikelBez + N' (Anzahl: ' + CAST(CAST(SUM(TeilSoFa.Menge) AS int) AS nvarchar) + N')'
    FROM TeilSoFa
    JOIN Artikel ON TeilSoFa.ArtikelID = Artikel.ID
    WHERE TeilSoFa.EinzHistID = EinzHist.ID
      AND Artikel.ArtiTypeID = 5
    GROUP BY Artikel.ArtikelBez
    FOR XML PATH ('')
  ), 1, 2, N'')
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
WHERE Kunden.KdNr = 272295
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.Archiv = 0
  AND EinzTeil.AltenheimModus = 0
  AND EinzHist.Status BETWEEN N'E' AND N'Z'
  AND Einzhist.Status NOT IN (N'X', N'XE', N'XI', N'XM');