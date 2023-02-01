/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pool-Entnahmen - fehlende Leasing-Berechnung                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, VaterVsa.GebaeudeBez AS Abteilung, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Traeger.Traeger, Traeger.PersNr, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, KdArti.Variante, Wochen.Woche, TraeArch.Effektiv AS [Anzahl Pool-Teile], CAST(LeasPreis.LeasPreisProWo AS float) AS [Leasingpreis wöchentlich], TraeArch.Effektiv * CAST(LeasPreis.LeasPreisProWo AS float) AS [Leasingbetrag]
FROM TraeArch
JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Wochen ON TraeArch.WochenID = Wochen.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Abteil ON TraeArch.AbteilID = Abteil.ID
JOIN Traeger AS VaterTraeger ON Traeger.ParentTraegerID = VaterTraeger.ID
JOIN Vsa AS VaterVsa ON VaterTraeger.VsaID = VaterVsa.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
CROSS APPLY advFunc_GetLeasPreisProWo(KdArti.ID) AS LeasPreis
WHERE Kunden.KdNr = 272295
  AND Vsa.VsaNr IN (902, 903)
  AND Traeger.ParentTraegerID > 0
  AND TraeArch.LeasPrKzID != 3
  AND TraeArch.AbtKdArWID < 0;