/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Ergänzt die SAP-Auswertung um weitere Details                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @jahrvon date, @jahrbis date;

SELECT @jahrvon = DATEADD(month, DATEDIFF(month, 0, GETDATE())-12, 0), 
       @jahrbis = DATEADD(month, DATEDIFF(month, -1, GETDATE())-1, -1);

DROP TABLE IF EXISTS #JahrLiefermenge;

SELECT KdArti.ArtikelID, CAST(IIF(Firma.Land = N'AT', 1, 0) AS bit) AS IsAT, SUM(LsPo.Menge) AS Liefermenge
INTO #JahrLiefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE LsKo.Datum BETWEEN @jahrvon AND @jahrbis
GROUP BY KdArti.ArtikelID, CAST(IIF(Firma.Land = N'AT', 1, 0) AS bit);

SELECT MaterialListe.Material, Artikel.Artikelnr, ArtGroe.Groesse, Bestand.Bestand, Bestand.Reserviert, Bestand.InFreigabe, Lagerart.LagerartBez,
  Standorte_mit_aktuellem_Umlauf = STUFF((
    SELECT DISTINCT N', ' + Standort.SuchCode
    FROM KdArti
    JOIN Kunden ON KdArti.KundenID = Kunden.ID
    JOIN Standort ON Kunden.StandortID = Standort.ID
    WHERE KdArti.ArtikelID = Artikel.ID
      AND KdArti.[Status] = N'A'
      AND Kunden.[Status] = N'A'
      and Kdarti.Umlauf > 0
    FOR XML PATH('')
  ), 1, 2, N''),
  Standorte = STUFF((
    SELECT DISTINCT N', ' + Standort.SuchCode
    FROM KdArti
    JOIN Kunden ON KdArti.KundenID = Kunden.ID
    JOIN Standort ON Kunden.StandortID = Standort.ID
    WHERE KdArti.ArtikelID = Artikel.ID
      AND KdArti.[Status] = N'A'
      AND Kunden.[Status] = N'A'
    FOR XML PATH('')
  ), 1, 2, N''),
  x.LiefmengeAT AS [Jahresliefermenge AT],
  x.LiefermengeCEE AS [Jahresliefermenge CEE/SEE]
FROM (SELECT DISTINCT Material COLLATE Latin1_General_CS_AS AS Material FROM __EKxlsx) AS MaterialListe
JOIN Artikel ON Artikel.ArtikelNr = MaterialListe.Material
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bestand ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Lagerart ON Lagerart.ID = Bestand.Lagerartid
JOIN Standort ON Standort.ID = Lagerart.LagerID
LEFT JOIN (
  SELECT ArtikelID, [1] AS LiefmengeAT, [0] AS LiefermengeCEE
  FROM (
    SELECT ArtikelID, IsAt, Liefermenge
    FROM #JahrLiefermenge
  ) AS JL
  PIVOT (
    SUM(Liefermenge)
    FOR IsAT IN ([1], [0])
  ) AS pvt
) AS x ON Artikel.ID = x.ArtikelID
WHERE ISNULL(MaterialListe.Material, N'') != N''
  AND Artikel.[Status] != 'I'
  AND ArtGroe.[Status] != 'I'
  AND Lagerart.LagerID = (SELECT Standort.ID FROM Standort WHERE Standort.SuchCode = N'SMZL')
  AND Bestand.Bestand != 0
  AND Lagerart.Neuwertig = 1;