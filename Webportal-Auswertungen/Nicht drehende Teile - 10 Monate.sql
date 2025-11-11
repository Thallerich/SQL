SELECT Teile.Barcode AS \"$lang_barcode\", Traeger.Vorname AS \"$lang_firstname\", Traeger.Nachname AS \"$lang_lastname\", Artikel.ArtikelNr AS \"$lang_article\", Artikel.ArtikelBez AS \"$lang_article_bez\", ArtGroe.Groesse AS \"$lang_groesse\", Teile.Eingang1 AS \"letzter Eingang Salesianer\", Teile.Ausgang1 AS \"letzte Lieferung\" " .
"FROM Teile " .
"JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID " .
"JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID " .
"JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID " .
"JOIN Traeger ON TraeArti.TraegerID = Traeger.ID " .
"WHERE Traeger.KundenID = " . $kundenID .
"  AND Teile.Eingang1 < DATE_ADD(CURRENT_DATE(), INTERVAL -10 MONTH) " .
"ORDER BY 3, 2, 4, ArtGroe.GroesseFolge;