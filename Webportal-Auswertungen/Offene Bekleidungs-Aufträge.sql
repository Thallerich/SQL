SELECT Kunden.KdNr AS \"$lang_custno\",
  VSA.VsaNr AS \"$lang_vsa_no\",
  Traeger.Traeger AS \"$lang_traeger\",
  Traeger.Vorname AS \"$lang_firstname\",
  Traeger.Nachname AS \"$lang_lastname\",
  Artikel.ArtikelNr AS \"$lang_article_no\",
  Artikel.ArtikelBez%LAN% AS \"$lang_bez\",
  ArtGroe.Groesse AS \"$lang_groesse\",
  IF(Teile.Status < 'N', '<unbekannt>', Teile.Barcode) AS \"$lang_barcode\",
  Teile.Lieferdatum AS \"$lang_delivery_date\"
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerId = Traeger.ID
JOIN VSA ON Traeger.VsaID = VSA.ID
JOIN Kunden ON VSA.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
WHERE Kunden.ID = " . $kundenID . "
  AND Teile.Status >= 'A'
  AND Teile.Status < 'Q'
  AND Traeger.Altenheim = 0;