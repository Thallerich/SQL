SELECT VSA.VsaNr AS \"$lang_vsa_no\", VSA.Bez AS \"$lang_vsa\", Artikel.ArtikelNr AS \"$lang_article_no\", Artikel.ArtikelBez AS \"$lang_article\", ArtGroe.Groesse AS \"$lang_article_size_short\" " .
"FROM VsaAnf " .
"JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID " .
"JOIN Artikel ON KdArti.ArtikelID = Artikel.ID " .
"JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID " .
"JOIN VSA ON VsaAnf.VsaID = VSA.ID " .
"WHERE VSA.KundenID = " . $kundenID . " ".
"AND VsaAnf.AbteilID IN (" .
"SELECT WebUAbt.AbteilID ".
"FROM WebUAbt ".
"WHERE WebUAbt.WebUserID = " . $webuserID .
") ".
"AND VSA.ID IN (".
"SELECT VSA.ID ".
"FROM VSA ".
"JOIN WebUser ON WebUser.KundenID = VSA.KundenID ".
"LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID ".
"WHERE WebUser.ID = ". $webuserID . " " .
"AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = VSA.ID) ".
") " .
"AND VSA.ID IN ($vsaids) " .
"ORDER BY 1, 3 ASC;