SELECT Kunden.Name1 AS Kunde, ISNULL(Traeger.Nachname + N' ,', N'') + ISNULL(Traeger.Vorname, N'') AS INHABER, Abteil.Bez AS Kst, TraeFach.Fach, Schrank.SchrankNr AS Schrank, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, EinzHist.Barcode AS Seriennummer, EinzHist.Ausgang1 AS Ausgang
FROM EinzHist
JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
LEFT JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
LEFT JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
WHERE Kunden.ID = $ID$
  AND EinzHist.Ausgang1 BETWEEN $1$ AND $2$ 
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
ORDER BY INHABER