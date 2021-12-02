SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, InvKo.Anlage_ AS [Inventur-Zeitpunkt], InvKo.Datum AS [Inventur für Datum], Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, InvPo.Menge AS [inventierte Menge]
FROM InvPo
JOIN InvKo ON InvPo.InvKoID = InvKo.ID
JOIN Vsa ON InvPo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON InvPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON InvPo.ArtGroeID = ArtGroe.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
WHERE Kunden.ID = $ID$
  AND InvKo.Anlage_ BETWEEN CAST($STARTDATE$ AS datetime2) AND CAST(DATEADD(day, 1, $ENDDATE$) AS datetime2)
ORDER BY [Inventur-Zeitpunkt], VsaNr, ArtikelNr, GroePo.Folge;