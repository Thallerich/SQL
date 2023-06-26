DECLARE @curweek nchar(7) = (SELECT Week.Woche FROM [WEEK] WHERE GETDATE() BETWEEN Week.VonDat AND Week.BisDat);

WITH Teilstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], Traeger.Traeger AS TrägerNr, Traeger.Vorname, Traeger.Nachname, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Barcode, Teilstatus.StatusBez AS [Status des Teils], EinzTeil.AlterInfo AS [Alter in Wochen], fRW.BasisAfa AS Neuwert, fRW.RestwertInfo AS [aktueller Restwert]
FROM EinzHist
CROSS APPLY funcGetRestwert(EinzHist.ID, @curweek, 1) AS fRW
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Eigentum ON KdArti.EigentumID = Eigentum.ID
JOIN Teilstatus ON EinzHist.[Status] = Teilstatus.[Status]
WHERE EinzHist.Archiv = 0
  AND EinzHist.IsCurrEinzHist = 1
  AND EinzHist.PoolFkt = 0
  AND EinzHist.EinzHistTyp = 1
  AND Traeger.Altenheim = 0
  AND Eigentum.RwFaktura = 1
  AND Kunden.KdNr = 10004603
  AND EinzHist.[Status] BETWEEN N'Q' AND N'W'
  AND EinzHist.Einzug IS NULL;