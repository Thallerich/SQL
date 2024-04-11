SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  EinzHist.Barcode,
  Traeger.Vorname,
  Traeger.Nachname,
  KdArti.Variante,
  KdArti.VariantBez AS Variantenbezeichnung,
  ArtGroe.Groesse AS Größe,
  EinzHist.Indienst,
  EinzHist.Ausdienst,
  EinzHist.Eingang1 AS [letzter Eingang],
  EinzHist.Ausgang1 AS [letzter Ausgang],
  EinzHist.RuecklaufK AS Waschzyklen,
  Vsa.VsaNr,
  Vsa.Bez AS [Vsa-Bezeichnung],
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  EinzHist.AusdRestw AS Restwert,
  [Verrechnet?] = CAST(IIF(EXISTS(SELECT TeilSoFa.* FROM TeilSoFa WHERE TeilSoFa.SoFaArt = N'R' AND TeilSoFa.EinzHistID = EinzHist.ID AND (TeilSoFa.RechPoID > 0 OR TeilSoFa.Status = N'L')), 1, 0) AS bit),
  Kaufware = CASE EinzHist.KaufwareModus WHEN 1 THEN N'Kaufware mit Waschauftrag' WHEN 2 THEN N'Kaufware ohne Waschauftrag' ELSE NULL END,
  Einsatz.EinsatzBez AS [Ausscheidungs-Grund],
  WegGrund.WeggrundBez AS [Schrott-Grund]
FROM EinzHist
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
LEFT JOIN Einsatz ON EinzHist.AusdienstGrund = Einsatz.EinsatzGrund
LEFT JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
WHERE Kunden.KdNr IN (30284,30285,30286,30287)
  AND EinzHist.[Status] IN (N'Y',N'Z')
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.Ausdienst >= N'2013/01';