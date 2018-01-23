DECLARE @PersNrLaenge INTEGER;
DECLARE @KundenNr INTEGER;

@PersNrLaenge = 4;  --Anzahl Stellen Personalnummer
@KundenNr = 11050;  --Kundennummer

TRY
  DROP TABLE #TmpTraePers;
CATCH ALL END;

SELECT Traeger.ID AS TraegerID, Traeger.Traeger, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, Traeger.PersNr, REPEAT('0', IIF(@PersNrLaenge - LENGTH(Traeger.PersNr) < 0, 0, @PersNrLaenge - LENGTH(Traeger.PersNr))) + TRIM(Traeger.PersNr) AS PersNrNeu
INTO #TmpTraePers
FROM Traeger, Vsa, Kunden
WHERE Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdNr = @KundenNr
  AND Traeger.PersNr IS NOT NULL;

EXECUTE PROCEDURE sp_EnableTriggers(NULL, NULL, FALSE, 0);

UPDATE Traeger SET Traeger.PersNr = TraePers.PersNrNeu
FROM Traeger, #TmpTraePers TraePers
WHERE Traeger.ID = TraePers.TraegerID;

SELECT Traeger, Titel, Vorname, Nachname, PersNr AS PersNr_Alt, PersNrNeu AS PersNr_Neu
FROM #TmpTraePers;