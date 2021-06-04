WITH PlatzStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Platz')
)
SELECT DISTINCT Platz.PlatzBez AS Platzierungsbezeichung, PlatzStatus.StatusBez AS [Status Platzierung], ArtiType.ArtiTypeBez AS [NS/EMBL], Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Standort.SuchCode AS Hauptstandort
FROM Platz
JOIN PlatzStatus ON Platz.[Status] = PlatzStatus.[Status]
JOIN KdArAppl ON KdArAppl.PlatzID = Platz.ID
JOIN KdArti ON KdArAppl.KdArtiID = KdArti.ID
JOIN KdArti AS ApplKdArti ON KdArAppl.ApplKdArtiID = ApplKdArti.ID
JOIN Artikel AS ApplArtikel ON ApplKdArti.ArtikelID = ApplArtikel.ID
JOIN ArtiType ON ApplArtikel.ArtiTypeID = ArtiType.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE LEFT(Platz.PlatzBez, 2) != N'PN'
  AND Platz.ID > 0
  AND Kunden.Status = N'A';

GO

WITH PlatzStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Platz')
)
SELECT DISTINCT Platz.PlatzBez AS Platzierungsbezeichung, PlatzStatus.StatusBez AS [Status Platzierung], ArtiType.ArtiTypeBez AS [NS/EMBL], Kunden.KdNr, Kunden.SuchCode AS Kunde, Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Standort.SuchCode AS Hauptstandort
FROM Platz
JOIN PlatzStatus ON Platz.[Status] = PlatzStatus.[Status]
JOIN KdArAppl ON KdArAppl.PlatzID = Platz.ID
JOIN KdArti ON KdArAppl.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdArti AS ApplKdArti ON KdArAppl.ApplKdArtiID = ApplKdArti.ID
JOIN Artikel AS ApplArtikel ON ApplKdArti.ArtikelID = ApplArtikel.ID
JOIN ArtiType ON ApplArtikel.ArtiTypeID = ArtiType.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE LEFT(Platz.PlatzBez, 2) != N'PN'
  AND Platz.ID > 0
  AND Kunden.Status = N'A';

GO

WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
)
SELECT Artikel.ArtikelNr AS [Änderungs-Code], Artikel.ArtikelBez AS Änderung, Platz.PlatzBez AS Platzierung, Artikelstatus.StatusBez AS [Status Änderung]
FROM ArtiMod
JOIN Artikel ON ArtiMod.ArtikelID = Artikel.ID
JOIN Platz ON ArtiMod.PlatzID = Platz.ID
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status];

GO

WITH PlatzStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Platz')
)
SELECT DISTINCT Platz.PlatzBez AS Platzierungsbezeichung, PlatzStatus.StatusBez AS [Status Platzierung], ApplArtikel.ArtikelNr AS [Änderungs-Code], ApplArtikel.ArtikelBez AS Änderung, Kunden.KdNr, Kunden.SuchCode AS Kunde, Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Standort.SuchCode AS Hauptstandort
FROM Platz
JOIN PlatzStatus ON Platz.[Status] = PlatzStatus.[Status]
JOIN TraeAppl ON TraeAppl.PlatzID = Platz.ID
JOIN TraeArti ON TraeAppl.TraeArtiID = TraeArti.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdArti AS ApplKdArti ON TraeAppl.ApplKdArtiID = ApplKdArti.ID
JOIN Artikel AS ApplArtikel ON ApplKdArti.ArtikelID = ApplArtikel.ID
JOIN ArtiType ON ApplArtikel.ArtiTypeID = ArtiType.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE LEFT(Platz.PlatzBez, 2) != N'PN'
  AND Platz.ID > 0
  AND Kunden.Status = N'A';

GO