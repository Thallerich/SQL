SELECT Kunden.KdNr, Kunden.ID AS KundenID, Vsa.Bez AS VsaBez, Abteil.Bez AS KsSt, Traeger.ID AS TraegerID, Traeger.PersNr, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, Traeger.SchrankInfo, EinzHist.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, ArtGroe.Groesse, EinzHist.Indienst, EinzHist.Ausdienst, EinzHist.Ausgang1, EinzHist.Eingang1, EinzHist.Ausgang2, EinzHist.Eingang2, EinzHist.Ausgang3, EinzHist.Eingang3, DATEDIFF(day, IIF(EinzHist.Eingang1 <= EinzHist.Ausgang1, Ausgang1, Eingang1), GETDATE()) AS Tage, EinzHist.Kostenlos, EinzHist.RuecklaufK
FROM EinzTeil, EinzHist, Traeger, Vsa, Kunden, Artikel, ArtGroe, Abteil
WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
  AND EinzHist.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND EinzHist.ArtikelID = Artikel.ID
  AND EinzHist.ArtGroeID = ArtGroe.ID
  AND Traeger.AbteilID = Abteil.ID
  AND Kunden.ID = $ID$
  AND EinzHist.Indienst IS NOT NULL
  AND Traeger.Status IN (N'A', N'K')
  AND EinzHist.Status BETWEEN N'Q' AND N'W'
  AND EinzHist.Status != N'T'
  AND EinzHist.Einzug IS NULL
  AND Artikel.BereichID IN ($1$)
  AND EinzHist.PoolFkt = 0
  AND EinzHist.EinzHistTyp = 1
ORDER BY VsaBez, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr;