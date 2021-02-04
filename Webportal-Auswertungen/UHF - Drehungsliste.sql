SELECT Kunden.KdNr AS Kundennummer,
  Kunden.SuchCode AS  [Kunden-Stichwort],
  Vsa.VsaNr AS [VSA-Nummer],
  Vsa.Bez AS [VSA-Bezeichnung],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  VsaAnfArti.Bestand AS Vertragsbestand,
  SUM(IIF(OPTeile.Status = N'Q', 1, 0)) AS [Teile beim Kunden],
  VsaAnfArti.Bestand - SUM(IIF(OPTeile.Status = N'Q', 1, 0)) AS [Differenz VB - Ist],
  SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) <= 7, 1, 0)) AS [stark drehend <= 7],
  SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > 7 AND DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) <= 30, 1, 0)) AS [schwach drehend <= 30],
  SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > 30 AND DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) <= 90, 1, 0)) AS [kaum drehend <= 90],
  SUM(IIF(DATEDIFF(day, OPTeile.LastScanToKunde, GETDATE()) > 90, 1, 0)) AS [nicht drehend > 90]
FROM OPTeile
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
LEFT JOIN (
  SELECT KdArti.ArtikelID, VsaAnf.VsaID, VsaAnf.Bestand
  FROM VsaAnf
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
) AS VsaAnfArti ON VsaAnfArti.VsaID = Vsa.ID AND VsaAnfArti.ArtikelID = Artikel.ID
WHERE Kunden.ID = $kundenID
  AND Vsa.ID IN (
    SELECT Vsa.ID
    FROM Vsa
    JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
    WHERE WebUser.ID = $webuserID
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
  )
  AND OPTeile.Status IN (N'Q')
  AND OPTeile.LastActionsID IN (102, 116)
  AND Artikel.BereichID != (SELECT ID FROM Bereich WHERE Bereich = N'LW')
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaAnfArti.Bestand
ORDER BY Kundennummer, [VSA-Nummer], ArtikelNr;