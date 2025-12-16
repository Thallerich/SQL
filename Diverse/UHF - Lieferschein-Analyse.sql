DECLARE @LsNr int = 59318062;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, LsKo.LsNr, FORMAT(LsKo.Datum, N'd', N'de-AT') AS Lieferdatum, AnfKo.AuftragsNr AS PackzettelNr, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, AnfPo.Angefordert, AnfPo.UrAngefordert, AnfPo.Geliefert AS [Liefermenge laut Packzettel], LsPo.Menge AS [Liefermenge laut LS], Mitarbei.Name AS [bestätigt von], AnfPo.BestaetZeitpunkt AS Bestätigungszeitpunkt, COUNT(DISTINCT EinzTeil.ID) AS [Anzahl gescannter Einzelteile], SUM(IIF(EinzTeil.LastScanTime > Scans.[DateTime], 1, 0)) AS [Anzahl Teile bereits retour]
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN LsPo ON LsPo.LsKoID = LsKo.ID AND LsPo.KdArtiID = AnfPo.KdArtiID AND LsPo.ArtGroeID = AnfPo.ArtGroeID AND LsPo.Kostenlos = AnfPo.Kostenlos
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Mitarbei ON AnfPo.BestaetUserID = Mitarbei.ID
LEFT JOIN Scans ON Scans.AnfPoID = AnfPo.ID
LEFT JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
WHERE LsKo.LsNr = @LsNr
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, LsKo.LsNr, FORMAT(LsKo.Datum, N'd', N'de-AT'), AnfKo.AuftragsNr, Artikel.ArtikelNr, Artikel.ArtikelBez, AnfPo.Angefordert, AnfPo.UrAngefordert, AnfPo.Geliefert, LsPo.Menge, Mitarbei.Name, AnfPo.BestaetZeitpunkt;

SELECT Contain.*
FROM Contain
JOIN LsCont ON LsCont.ContainID = Contain.ID
LEFT OUTER JOIN LsKo ON LsCont.LsKoID = LsKo.ID
WHERE (
  LsKo.LsNr = @LsNr
  OR
  LsCont.AnfKoID = (
    SELECT AnfKo.ID
    FROM AnfKo
    JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
    WHERE LsKo.LsNr = @LsNr)
);



SELECT LsKo.LsNr
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN LsKo ON AnfKo.LsKoID = LsKo.ID
JOIN LsPo ON LsPo.LsKoID = LsKo.ID AND LsPo.KdArtiID = AnfPo.KdArtiID AND LsPo.ArtGroeID = AnfPo.ArtGroeID AND LsPo.Kostenlos = AnfPo.Kostenlos
/* JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
LEFT JOIN Scans ON Scans.AnfPoID = AnfPo.ID
LEFT JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID */
WHERE LsKo.LsNr = 59318062;