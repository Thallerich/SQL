DECLARE @Traeger TABLE (
  TraegerID int,
  Titel nvarchar(20) COLLATE Latin1_General_CS_AS,
  Vorname nvarchar(20) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(25) COLLATE Latin1_General_CS_AS,
  NS bit,
  Namenschild1 nvarchar(40) COLLATE Latin1_General_CS_AS,
  Namenschild2 nvarchar(40) COLLATE Latin1_General_CS_AS,
  Namenschild3 nvarchar(40) COLLATE Latin1_General_CS_AS,
  Namenschild4 nvarchar(40) COLLATE Latin1_General_CS_AS,
  Namenschild1_Neu nvarchar(40) COLLATE Latin1_General_CS_AS
);

DECLARE @KdArti TABLE (
  KdArtiID int,
  KundenID int,
  NsNeuID int DEFAULT -1
);

INSERT INTO @Traeger
SELECT Traeger.ID AS TraegerID, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, Traeger.NS, Traeger.Namenschild1, Traeger.Namenschild2, Traeger.Namenschild3, Traeger.Namenschild4, LTRIM(RTRIM(ISNULL(Traeger.Titel, N'') + N' ' + ISNULL(Traeger.Vorname, N'') + N' ' + ISNULL(Traeger.Nachname, N''))) AS Namenschild1_Neu
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = 7100 --IN (7070, 7077, 7080, 7081, 7083, 7090, 7100, 7110, 7130, 7135, 7139, 7140, 7150, 7155, 7156, 7157, 7160, 7161, 7162, 7170, 7180)
  AND Traeger.NS = 1;

INSERT INTO @KdArti (KdArtiID, KundenID)
SELECT KdArti.ID AS KdArtiID, KdArti.KundenID
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
WHERE KdArti.NsKdArtiID IN (SELECT x.ID FROM KdArti AS x JOIN Artikel ON x.ArtikelID = Artikel.ID WHERE Artikel.ArtikelNr = N'N006001' AND KdArti.KundenID = Kunden.ID)
  AND Kunden.KdNr = 7100 --IN (7070, 7077, 7080, 7081, 7083, 7090, 7100, 7110, 7130, 7135, 7139, 7140, 7150, 7155, 7156, 7157, 7160, 7161, 7162, 7170, 7180);

UPDATE NsArti SET NsNeuID = KdArti.ID
FROM @KdArti AS NsArti
JOIN KdArti ON KdArti.KundenID = NsArti.KundenID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Artikel.ArtikelNr = N'N006000';

-- Check for missing NS-KdArti
-- SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode FROM @KdArti AS KdArti JOIN Kunden ON KdArti.KundenID = Kunden.ID WHERE KdArti.NsNeuID < 0;

UPDATE Traeger SET Traeger.Namenschild1 = T.Namenschild1_Neu, Traeger.Namenschild2 = NULL, Traeger.Namenschild3 = NULL, Traeger.Namenschild4 = NULL
FROM Traeger
JOIN @Traeger AS T ON T.TraegerID = Traeger.ID;

UPDATE KdArti SET KdArti.NsKdArtiID = NsArti.NsNeuID
FROM KdArti
JOIN @KdArti AS NsArti ON NsArti.KdArtiID = KdArti.ID
WHERE NsArti.NsNeuID > 0;

INSERT INTO Hinweis (TeileID, Aktiv, StatusSDC, Hinweis, BisWoche, Anzahl, HinwTextID, EingabeDatum, EingabeMitarbeiID, Wichtig)
SELECT Teile.ID AS TeileID, CAST(1 AS bit) AS Aktiv, N'A' AS StatusSDC, N'<o> Magazinstange: Namensschild ändern!' AS Hinweis, N'2099/52' AS BisWoche, 1 AS Anzahl, 172 AS HinwTextID, CAST(GETDATE() AS date) AS EingabeDatum, (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'THALST') AS EingabeMitarbeID, CAST(1 AS bit) AS Wichtig
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti AS NsKdArti ON KdArti.NsKdArtiID = NsKdArti.ID
JOIN Artikel AS NsArtikel ON NsKdArti.ArtikelID = NsArtikel.ID
WHERE Kunden.KdNr = 7100 --IN (7077, 7080, 7081, 7083, 7090, 7110, 7130, 7135, 7139, 7140, 7150, 7156, 7160, 7161, 7162, 7170, 7180)
  AND NsArtikel.ArtikelNr = N'N006000'
  AND Teile.Status BETWEEN N'M' AND N'Q'
  AND Traeger.NS = 1;