USE Wozabal
GO

SELECT Wochen.Woche AS KW, Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger, Traeger.Titel, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, TraeArch.Menge
FROM TraeArch, TraeArti, Traeger, Vsa, Kunden, KdArti, Artikel, Wochen, ArtGroe
WHERE TraeArch.TraeArtiID = TraeArti.ID
  AND TraeArti.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND TraeArti.ArtGroeID = ArtGroe.ID
  AND TraeArti.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND TraeArch.WochenID = Wochen.ID
  AND Kunden.KdNr IN (2529299, 2529328)
  AND Wochen.Woche IN (N'2014/52', N'2015/52', N'2016/52')

GO