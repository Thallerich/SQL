SELECT Artikel.ArtikelNr, COUNT(EinzTeil.ID) AS [Anzahl Ersatzteile]
FROM Kunden
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdArti ErsatzKdArti ON ErsatzKdArti.ErsatzFuerKdArtiID = KdArti.ID
JOIN EinzTeil ON EinzTeil.VsaID = Vsa.ID AND EinzTeil.ArtikelID = ErsatzKdArti.ArtikelID
WHERE Kunden.KdNr = 11208
  AND Artikel.ArtikelNr IN (N'41001983512', N'41001983514', N'41501983516', N'143001883550', N'143001883551')
  AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 154)
  AND EinzTeil.LastErsatzFuerKdArtiID != 0
  AND EinzTeil.LastErsatzArtGroeID = -1
GROUP BY Artikel.ArtikelNr;

GO

SELECT EinzTeil.ID, EinzTeil.Code, EinzTeil.[Status], ErsatzArtikel.ArtikelNr, ErsatzArtikel.ArtikelBez, ArtGroe.Groesse, EinzTeil.LastActionsID, EinzTeil.LastErsatzFuerKdArtiID, EinzTeil.LastErsatzArtGroeID
FROM Kunden
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdArti ErsatzKdArti ON ErsatzKdArti.ErsatzFuerKdArtiID = KdArti.ID
JOIN Artikel ErsatzArtikel ON ErsatzKdArti.ArtikelID = ErsatzArtikel.ID
JOIN EinzTeil ON EinzTeil.VsaID = Vsa.ID AND EinzTeil.ArtikelID = ErsatzKdArti.ArtikelID
JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
WHERE Kunden.KdNr = 11208
  AND Artikel.ArtikelNr IN (N'143001883551')
  AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 154);

GO

UPDATE EinzTeil SET LastErsatzFuerKdArtiID = -1
WHERE ID IN (
  SELECT EinzTeil.ID
  FROM Kunden
  JOIN Vsa ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON KdArti.KundenID = Kunden.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdArti ErsatzKdArti ON ErsatzKdArti.ErsatzFuerKdArtiID = KdArti.ID
  JOIN EinzTeil ON EinzTeil.VsaID = Vsa.ID AND EinzTeil.ArtikelID = ErsatzKdArti.ArtikelID
  WHERE Kunden.KdNr = 11208
    AND Artikel.ArtikelNr IN (N'143001883551')
    AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 154)
    AND EinzTeil.LastErsatzFuerKdArtiID != 0
    AND EinzTeil.LastErsatzArtGroeID = -1
);

GO