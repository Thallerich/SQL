-- Durchschnittliche Lagerdauer (360 Tage x Ø Lagerbestand / Verbrauch pro Jahr) auf Artikel Ebene (TOP xx) _Unterteilung in BU’s

DECLARE @startofmonth datetime2 = DATETIME2FROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1, 0, 0, 0, 0, 0);
DECLARE @lagerid int = (SELECT Standort.ID FROM Standort WHERE SuchCode = N'SMZL');

SELECT ArtikelNr, Artikelbezeichnung, Größe, SUM(BestandSchnittLagerart) AS [durchschnitt. Lagerbestand], SUM(EntnahmeJahr) AS Entnahmemenge, 360 * SUM(BestandSchnittLagerart) / IIF(SUM(EntnahmeJahr) = 0, 1, SUM(EntnahmeJahr)) AS [durchschnitt. Lagerdauer]
FROM (
  SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Bestand.LagerartID, AVG(CAST(LagerBew.BestandNeu AS bigint)) AS BestandSchnittLagerart, Bestand.Entnahme01 + Bestand.Entnahme02 + Bestand.Entnahme03 + Bestand.Entnahme04 + Bestand.Entnahme05 + Bestand.Entnahme06 + Bestand.Entnahme07 + Bestand.Entnahme08 + Bestand.Entnahme09 + Bestand.Entnahme10 + Bestand.Entnahme11 + Bestand.Entnahme12 AS EntnahmeJahr
  FROM LagerBew
  JOIN Bestand ON LagerBew.BestandID = Bestand.ID
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  WHERE LagerBew.Zeitpunkt BETWEEN DATEADD(year, -1, @startofmonth) AND @startofmonth
    AND Bestand.LagerArtID IN (SELECT Lagerart.ID FROM Lagerart WHERE LagerID = @lagerid AND Lagerart.Neuwertig = 1)
    AND LagerBew.BestandNeu != 0
    AND Artikel.ArtiTypeID = 1 /* nur textile Artikel - keine Embleme, ... */
    AND LagerBew.LgBewCodID != (SELECT LgBewCod.ID FROM LgBewCod WHERE Code = N'WKOR')
  GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, Bestand.LagerArtID, Bestand.Entnahme01 + Bestand.Entnahme02 + Bestand.Entnahme03 + Bestand.Entnahme04 + Bestand.Entnahme05 + Bestand.Entnahme06 + Bestand.Entnahme07 + Bestand.Entnahme08 + Bestand.Entnahme09 + Bestand.Entnahme10 + Bestand.Entnahme11 + Bestand.Entnahme12
) AS AvgBestandPerLagerart
GROUP BY ArtikelNr, Artikelbezeichnung, Größe;