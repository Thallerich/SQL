/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline (vorbereitend): LoadChips                                                                                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @sqltext nvarchar(max);

IF OBJECT_ID(N'tempdb..#Scans989a') IS NOT NULL
  TRUNCATE TABLE #Scans989a;
ELSE
  CREATE TABLE #Scans989a (
    Code nvarchar(33) COLLATE Latin1_General_CS_AS,
    LsPoID int
  );

SET @sqltext = N'
INSERT INTO #Scans989a (Code, LsPoID)
SELECT EinzTeil.Code, Scans.LsPoID
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
  AND Scans.EinzTeilID > 0
  AND Scans.AnfPoID IN (
    SELECT AnfPo.ID
    FROM AnfPo, AnfKo, LsKo
    WHERE AnfPo.AnfKoID = AnfKo.ID
      AND AnfKo.LsKoID = LsKo.ID
      AND LsKo.LsNr = @P1
);';

EXEC sp_executesql @sqltext, N'@P1 int', $1$;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline (Main): ChipsZuLieferschein                                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], LsKo.LsNr, LsKo.Datum AS Lieferdatum, AnfKo.AuftragsNr AS Packzettelnummer, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, IIF(DATEDIFF(minute, AnfPo.Anlage_, AnfPo.BestaetZeitpunkt) = 0, 0, AnfPo.Angefordert) AS Angefordert, LsPo.Menge AS Liefermenge, LsPo.Kostenlos AS [Lieferschein-Position kostenlos], Scans.Code AS Chipcode
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN LsPo ON LsPo.LsKoID = LsKo.ID AND LsPo.KdArtiID = KdArti.ID AND AnfPo.Kostenlos = LsPo.Kostenlos
JOIN #Scans989a AS Scans ON Scans.LsPoID = LsPo.ID
WHERE LsKo.LsNr = $1$
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0);