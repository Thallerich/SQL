DECLARE @KundenID int = $1$;

DECLARE @AnzahlAnsprechpartner int = 0;
DECLARE @AnzahlBKTraeger int = 0;
DECLARE @AnzahlBewohner int = 0;

SET @AnzahlAnsprechpartner = (
  SELECT COUNT(SachbearID) AS AnzAnsprechpartner
  FROM (
    SELECT Kunden.ID AS KundenID, Sachbear.ID AS SachbearID
    FROM Sachbear
    JOIN Kunden ON Sachbear.TableID = Kunden.ID AND Sachbear.TableName = N'KUNDEN'
    WHERE Kunden.ID = @KundenID

    UNION ALL

    SELECT Vsa.KundenID, Sachbear.ID AS SachbearID
    FROM Sachbear
    JOIN Vsa ON Sachbear.TableID = Vsa.ID AND Sachbear.TableName = N'VSA'
    WHERE Vsa.KundenID = @KundenID
  ) AS Ansprechpartner
);

SET @AnzahlBKTraeger = (
  SELECT COUNT(Traeger.ID) AS AnzBKTraeger
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  WHERE Vsa.KundenID = @KundenID
    AND Traeger.Status IN (N'A', N'K')
    AND Traeger.Altenheim = 0
);

SET @AnzahlBewohner = (
  SELECT COUNT(Traeger.ID) AS AnzBewohner
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  WHERE Vsa.KundenID = @KundenID
    AND Traeger.Status IN (N'A', N'K')
    AND Traeger.Altenheim = 1
);

SELECT *
FROM (
  SELECT IIF(@AnzahlAnsprechpartner > 0, N'Ansprechpartner: Anrede, Titel, Vorname, Nachname, Telefon, Handy, Abteilung, Position im Unternehmen, E-Mail', NULL) AS [Gespeicherte Daten] 
  UNION ALL SELECT IIF(@AnzahlBKTraeger > 0, N'Träger: Nachname, Vorname, Titel, Schrank-Fach-Nummer, Größen, Namenschild ja/nein, Maße, Berufsgruppe', NULL) AS [Gespeicherte Daten]
  UNION ALL SELECT IIF(@AnzahlBewohner > 0, N'Bewohner: ZimmerNr, Nachname, Vorname', NULL) AS [Gespeicherte Daten]
) AS x
WHERE x.[Gespeicherte Daten] IS NOT NULL;