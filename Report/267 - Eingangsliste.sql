SELECT Kunden.Name1 AS Kunde, ISNULL(Traeger.Nachname + N', ', N'') + ISNULL(Traeger.Vorname, N'') AS Inhaber, Abteil.Bez AS Kst, TraeFach.Fach, Schrank.SchrankNr AS Schrank, Artikel.ArtikelNr AS Kurzbezeichnung, Artikel.ArtikelBez$LAN$ AS Artikel, ArtGroe.Groesse, EinzHist.Barcode AS Seriennummer, EinzHist.Eingang1 AS Eingang, EinzHist.Ausgang1 as Ausgang
FROM EinzHist 
JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Traeger ON Traeger.ID = EinzHist.TraegerID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
LEFT JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
LEFT JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
WHERE Kunden.ID = $ID$
  AND EinzHist.Eingang1 BETWEEN $1$ AND $2$
  AND EinzHist.PoolFkt = 0
  AND EinzHist.EinzHistTyp = 1;