SELECT Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, Actions.ActionsBez AS Aktion, Scans.DateTime AS Entnahmezeitpunkt, Lieferscheine = (
  STUFF((
    SELECT N', ' + CAST(LsKo.LsNr AS nvarchar) + N': ' + FORMAT(LsKo.Datum, N'd', N'de-AT')
    FROM Scans AS s
    JOIN LsPo ON s.LsPoID = LsPo.ID
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID
    WHERE s.TeileID = Scans.TeileID
      AND s.DateTime = Scans.DateTime
      AND s.LsPoID > 0
    FOR XML PATH('')
  ), 1, 2, N'')
)
FROM Scans
JOIN Teile ON Scans.TeileID = Teile.ID
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Actions ON Scans.ActionsID = Actions.ID
WHERE Kunden.KdNr = 10004231
  AND Scans.LsPoID > 0
GROUP BY Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Actions.ActionsBez, Scans.TeileID, Scans.DateTime
HAVING COUNT(Scans.ID) > 1;