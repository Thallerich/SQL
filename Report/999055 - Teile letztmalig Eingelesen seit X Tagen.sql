WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT Produktion.SuchCode AS Produktion, Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger AS [Träger-Nr.], Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.Barcode, Teilestatus.StatusBez AS [Status Teil], EinzHist.Eingang1 AS [letzter Eingang], EinzHist.Ausgang1 AS [letzter Ausgang], DATEDIFF(day, EinzHist.Eingang1, GETDATE()) AS [Anzahl Tage in Produktion]
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = KdBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
WHERE EinzHist.Status BETWEEN N'Q' AND N'W'
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
  AND Produktion.ID IN ($1$)
  AND ISNULL(EinzHist.Eingang1, N'2099-12-31') > ISNULL(EinzHist.Ausgang1, N'1980-01-01')
  AND EinzHist.Einzug IS NULL
  AND EinzHist.Ausdienst IS NULL
  AND DATEDIFF(day, EinzHist.Eingang1, GETDATE()) >= $2$
  AND Kunden.Kdnr NOT IN (10002703, 213981, 10002706, 220545, 272466, 10000061, 10002030, 1004492, 10002360, 10002361, 23041, 23042, 23044, 23046, 23037, 7240, 20000, 20150, 10001662, 10001828, 10001826, 19080, 10003460, 10003465, 10003473, 10005566, 31063, 31064, 31065, 31066, 293712, 181845, 181846, 293713, 10004231, 261774, 10003349, 2500002, 112157, 10004497, 10003106, 10004516, 10004492)
ORDER BY KdNr, ArtikelNr, [Träger-Nr.], GroePo.Folge;