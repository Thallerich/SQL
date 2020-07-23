DECLARE @Woche nchar(7) = N'2020/27';

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS VsaBezeichnung, Traeger.Traeger AS TraegerNr, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, KdArti.Variante, KdArti.VariantBez, Teile.Erstwoche AS [Ersteinsatz-Woche], Teile.Indienst AS [Indienststellung aktueller Träger], IIF(ISNULL(Teile.Eingang1, N'1980-01-01') > ISNULL(Teile.Ausgang1, N'2099-12-31'), Teile.Eingang1, Teile.Ausgang1) AS LetzterScan, Restwert.AlterInfo AS [Alter in Wochen], Restwert.BasisAfa AS Wiederbeschaffungswert, IIF(Teile.Status IN (N'Z', N'V', N'X', N'Y') OR (Teile.Einzug < CONVERT(DATE, GETDATE())), 0, IIF((Teile.AusDienst = N'' OR Teile.AusDienst IS NULL), Restwert.RestwertInfo, IIF(@Woche < Teile.AusDienst, Restwert.RestWertInfo, Teile.AusDRestW))) AS RestWert, IIF(Restwert.AlterInfo > KdArti.AfaWochen, 100, ROUND(100 / CAST(KdArti.AfaWochen AS float) * CAST(Restwert.AlterInfo AS float), 2)) AS [Abnützung in %]
FROM Teile
CROSS APPLY funcGetRestwert(Teile.ID, @Woche, 1) AS Restwert
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
WHERE Kunden.KdNr IN (218645, 219733, 299156, 10002344)
  AND Teile.Status != N'5';