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
WHERE Kunden.KdNr IN (7077, 7080, 7081, 7083, 7090, 7110, 7130, 7135, 7139, 7140, 7150, 7156, 7160, 7161, 7162, 7170, 7180)
  AND NsArtikel.ArtikelNr = N'N006000'
  AND Teile.Status BETWEEN N'M' AND N'Q'
  AND Traeger.NS = 1;