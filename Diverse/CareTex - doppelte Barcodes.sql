SELECT Firma.SuchCode AS Firma, Standort.Bez AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Teile.Barcode, Teile.Eingang1 AS [letzter Eingang], Teile.Ausgang1 AS [letzter Ausgang]
FROM Teile
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Traeger.Altenheim = 1
  AND EXISTS (
    SELECT T.*
    FROM Teile AS T
    WHERE REPLACE(T.Barcode, N'*SAL', N'') = REPLACE(Teile.Barcode, N'*SAL', N'')
      AND T.ID <> Teile.ID
  );