DROP TABLE IF EXISTS #TmpLKontrolle889;

SELECT LsKo.Datum, AnfKo.AuftragsNr AS Packzettel, LsKo.LsNr AS Lieferschein, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, RTRIM(CONVERT(char(10), BKunde.KdNr)) + ' - ' + RTRIM(BKunde.SuchCode) AS [Besitzer Kunde], RTRIM(BVsa.SuchCode) + ' - ' + RTRIM(BVsa.Bez) AS [Besitzer VSA], RTRIM(CONVERT(char(10), GKunde.KdNr)) + ' - ' + RTRIM(GKunde.Suchcode) AS [Geliefert Kunde], RTRIM(GVsa.SuchCode) + ' - ' + RTRIM(GVsa.Bez) AS [Geliefert VSA], COUNT(DISTINCT EinzTeil.ID) AS Liefermenge, LsKo.ID AS LsKoID, AnfPo.KdArtiID, CONVERT(bit, IIF(AnfKo.VsaID <> EinzTeil.VsaOwnerID, 1, 0)) AS Falsch
INTO #TmpLKontrolle889
FROM Scans, AnfPo, AnfKo, LsKo, EinzTeil, Artikel, Vsa AS BVsa, Kunden AS BKunde, Vsa AS GVsa, Kunden AS GKunde
WHERE Scans.AnfPoID = AnfPo.ID
  AND AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.LsKoID = LsKo.ID
  AND Scans.EinzTeilID = EinzTeil.ID
  AND EinzTeil.ArtikelID = Artikel.ID
  AND EinzTeil.VsaOwnerID = BVsa.ID
  AND BVsa.KundenID = BKunde.ID
  AND AnfKo.VsaID = GVsa.ID
  AND GVsa.KundenID = GKunde.ID
  AND LsKo.Datum = $1$
  AND EinzTeil.VsaOwnerID > 0
  AND GVsa.StandKonID IN ($2$)
GROUP BY LsKo.Datum, AnfKo.AuftragsNr, LsKo.LsNr, Artikel.ArtikelNr, Artikel.ArtikelBez, RTRIM(CONVERT(char(10), BKunde.KdNr)) + ' - ' + RTRIM(BKunde.SuchCode), RTRIM(BVsa.SuchCode) + ' - ' + RTRIM(BVsa.Bez), RTRIM(CONVERT(char(10), GKunde.KdNr)) + ' - ' + RTRIM(GKunde.Suchcode), RTRIM(GVsa.SuchCode) + ' - ' + RTRIM(GVsa.Bez), LsKo.ID, AnfPo.KdArtiID, CONVERT(bit, IIF(AnfKo.VsaID <> EinzTeil.VsaOwnerID, 1, 0));

SELECT Datum, Packzettel, Lieferschein, ArtikelNr, Artikelbezeichnung, [Besitzer Kunde], [Besitzer VSA], [Geliefert Kunde], [Geliefert VSA], Liefermenge, Falsch AS [Falsch Geliefert]
FROM #TmpLKontrolle889
ORDER BY Datum, Lieferschein, ArtikelNr;