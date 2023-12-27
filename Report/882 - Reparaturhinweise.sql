DECLARE @EingabeDatumVon datetime2;
DECLARE @EingabeDatumBis datetime2;

SET @EingabeDatumVon = CAST($STARTDATE$ AS datetime2);
SET @EingabeDatumBis = CAST(DATEADD(day, 1, $ENDDATE$) AS datetime2);

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, EinzHist.Barcode, EinzHist.RestwertInfo AS RestwertAktuell, Hinweis.Hinweis, Hinweis.Aktiv, CAST(Hinweis.EingabeDatum AS date) AS [Hinweis erfasst am], EingabeMitarbei.Name AS [Erfasst von], CAST(Hinweis.BestaetDatum AS date) AS [Bestätigt am], BestaetMitarbei.Name AS [Bestätigt von], EinzHist.Eingang1 AS [letzter Eingang], EinzHist.Ausgang1 AS [letzter Ausgang], Actions.ActionsBez$LAN$ AS [letzte Aktion]
FROM Hinweis
JOIN EinzHist ON Hinweis.EinzHistID = EinzHist.ID
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Mitarbei AS EingabeMitarbei ON Hinweis.EingabeMitarbeiID = EingabeMitarbei.ID
JOIN Mitarbei AS BestaetMitarbei ON Hinweis.BestaetMitarbeiID = BestaetMitarbei.ID
JOIN Actions ON EinzTeil.LastActionsID = Actions.ID
WHERE Hinweis.HinwTextID IN ($3$)
  AND Hinweis.EingabeDatum BETWEEN @EingabeDatumVon AND @EingabeDatumBis
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);