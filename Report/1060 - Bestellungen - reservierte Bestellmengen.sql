DECLARE @BPoInfo TABLE (
  BKoID int,
  BestNr bigint,
  Datum date,
  BKoStatus nvarchar(40) COLLATE Latin1_General_CS_AS,
  BPoID int,
  Pos int,
  ArtGroeID int
);

INSERT INTO @BPoInfo (BKoID, BestNr, Datum, BKoStatus, BPoID, Pos, ArtGroeID)
SELECT BKo.ID AS BKoID, BKo.BestNr, BKo.Datum, BKoStatus.StatusBez, BPo.ID AS BPoID, BPo.Pos, BPo.ArtGroeID
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN (
  SELECT [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'BKO'
) AS BKoStatus ON BKo.[Status] = BKoStatus.[Status]
WHERE BKo.LagerID = $1$
  AND BKo.[Status] IN (N'B', N'D', N'E', N'F', N'J')
  AND BPo.Menge > BPo.LiefMenge;

SELECT BPoInfo.BKoID, BPoInfo.BestNr, BPoInfo.bKoStatus AS [Status Bestellung], BPoInfo.Datum AS Bestelldatum, BPoInfo.Pos AS Bestellposition, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Kunden.KdNr, Kunden.SuchCode AS Kunde, COUNT(TeileBPo.ID) AS [Menge reserviert]
FROM @BPoInfo AS BPoInfo
JOIN TeileBPo ON TeileBPo.BPoID = BPoInfo.BPoID
JOIN EinzHist ON TeileBPo.EinzHistID = EinzHist.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN ArtGroe ON BPoInfo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
GROUP BY BPoInfo.BKoID, BPoInfo.BestNr, BPoInfo.BKoStatus, BPoInfo.Datum, BPoInfo.Pos, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Kunden.KdNr, Kunden.SuchCode

UNION ALL

SELECT BPoInfo.BKoID, BPoInfo.BestNr, BPoInfo.bKoStatus AS [Status Bestellung], BPoInfo.Datum AS Bestelldatum, BPoInfo.Pos AS Bestellposition, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Kunden.KdNr, Kunden.SuchCode AS Kunde, SUM(BPoRes.Menge - BPoRes.LiefMenge) AS [Menge reserviert]
FROM @BPoInfo AS BPoInfo
JOIN BPoRes ON BPoRes.LaufendeBPoID = BPoInfo.BPoID
JOIN BPo AS UmbuchBPo ON BPoRes.UmbuchBPoID = UmbuchBPo.ID
JOIN BKo AS UmbuchBKo ON UmbuchBPo.BKoID = UmbuchBKo.ID
LEFT JOIN Kunden ON UmbuchBKo.KundenID = Kunden.ID
JOIN ArtGroe ON BPoInfo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
GROUP BY BPoInfo.BKoID, BPoInfo.BestNr, BPoInfo.bKoStatus, BPoInfo.Datum, BPoInfo.Pos, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Kunden.KdNr, Kunden.SuchCode
ORDER BY BestNr ASC;