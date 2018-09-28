DROP TABLE IF EXISTS #Temp604;

SELECT DISTINCT KdArtiID, VsaID, 'Schrank' AS Typ
INTO #Temp604
FROM Schrank, Week
WHERE Week.VonDat <= CONVERT(date, GETDATE())
  AND Week.BisDat >= CONVERT(date, GETDATE())
  AND ISNULL(Schrank.Ausdienst, '2099/52') > Week.Woche
UNION
SELECT DISTINCT KdArtiID, VsaID, 'Mengenleasing' AS Typ
FROM VsaLeas, Week
WHERE Week.VonDat <= CONVERT(date, GETDATE())
  AND Week.BisDat >= CONVERT(date, GETDATE())
  AND ISNULL(VsaLeas.Ausdienst, '2099/52') > Week.Woche
UNION
SELECT DISTINCT KdArtiID, VsaID, 'Anforderungs-Artikel' AS Typ
FROM VsaAnf
WHERE Art <> 'm'
UNION
SELECT DISTINCT KdArtiID, VsaID, 'TPS' AS Typ
FROM Strumpf
UNION
SELECT DISTINCT KdArtiID, VsaID, 'Teile' AS Typ
FROM Teile
WHERE Status >= 'A'
  AND Status <= 'Q';

-- fehlende Vsa-Bereiche für aktive Kunden, VSAs und Kunden-Bereiche
SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode, x.VsaID, Vsa.VsaNr, Vsa.Bez, ISNULL(KdBer.Bez, Bereich.BereichBez$LAN$) AS Bereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, x.Typ AS Quelle
FROM #Temp604 x, KdArti, Vsa, Kunden, KdBer, Bereich, Artikel
WHERE x.KdArtiID = KdArti.ID
  AND x.VsaID = Vsa.ID
  AND KdArti.KdberID = KdBer.ID
  AND KdBer.KundenID = Kunden.ID
  AND KdBer.BereichID = Bereich.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.Status = 'A'
  AND VSA.Status = 'A'
  AND KdBer.Status = 'A'
  AND NOT EXISTS (SELECT ID FROM VsaBer WHERE VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID)
  AND Artikel.ID > 0
  AND Kunden.FirmaID IN ($1$)
ORDER BY x.VsaID, Bereich;