CREATE OR ALTER VIEW [sapbw].[V_BW_BESTAND] AS
SELECT 'ADV' AS [System],
	Bestand.ID AS BestandID,
	Bestand.Bestand,
	Bestand.Reserviert,
	Bestand.Minimum,
	Bestand.Maximum,
	Bestand.LetzteBewegung,
	Bestand.Umlauf,
	Bestand.EntnahmeJahr,
	Lagerart.LagerArt,
	lagerart.IstAnfLager,
	Lagerart.ArtiTypeID,
	LagerStandort = IIF(Standort.SuchCode = N'SALESIANER MIET', SUBSTRING(Standort.Bez, CHARINDEX(N' ', Standort.Bez, 1) + 1, CHARINDEX(N':', Standort.Bez, 1) - CHARINDEX(N' ', Standort.Bez, 1) - 1), IIF(Standort.Bez like '%ehem. Asten%','SMA', Standort.SuchCode)),
  ArtikelNr = UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)),
  Lief.LiefNr,
	LetzteZubuchung = (
    SELECT MAX(LagerBew.Zeitpunkt)
    FROM Salesianer.dbo.LagerBew
    JOIN Salesianer.dbo.LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
		WHERE LgBewCod.IstEntnahme = 0 
      AND LgBewCod.Code != N'WKOR' /* Wertkorrektur führt immer eine Plus- und Minus-Buchung aus, um den Wert zu korrigieren, der Bestand bleibt aber tatsächlich unverändert */
      AND LagerBew.BestandID = Bestand.ID
  ),
	LetzteAbbuchung = (
    SELECT MAX(LagerBew.Zeitpunkt)
    FROM Salesianer.dbo.LagerBew
    JOIN Salesianer.dbo.LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
		WHERE LgBewCod.IstEntnahme = 1 
      AND LagerBew.BestandID = Bestand.ID
  )
FROM Salesianer.dbo.Bestand
JOIN Salesianer.dbo.LagerArt ON Bestand.LagerArtID = LagerArt.ID
JOIN Salesianer.dbo.Standort ON Lagerart.LagerID = Standort.ID
JOIN Salesianer.dbo.ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Salesianer.dbo.Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Salesianer.dbo.Lief ON Artikel.LiefID = Lief.ID
WHERE Bestand.LetzteBewegung >= DATEADD(day, -10, CAST(CAST(GETDATE() AS date) AS datetime2));