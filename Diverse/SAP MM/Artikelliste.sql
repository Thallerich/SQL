WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
),
Rechnungsartikel AS (
  SELECT DISTINCT KdArti.ArtikelID
  FROM RechPo
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
  WHERE RechKo.RechDat BETWEEN N'2018-04-01' AND N'2019-03-31'
),
LieferscheinArtikel AS (
  SELECT DISTINCT KdArti.ArtikelID
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  WHERE LsKo.Datum BETWEEN N'2018-04-01' AND N'2019-03-31'
    AND LsPo.Menge <> 0
),
Lagerbestand AS (
  SELECT DISTINCT ArtGroe.ArtikelID
  FROM Bestand
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
  JOIN (
    SELECT LagerBew.BestandID, LagerBew.BestandNeu
    FROM LagerBew
    JOIN (
      SELECT LBID.BestandID, MAX(LBID.ID) AS ID
      FROM LagerBew AS LBID
      JOIN (
        SELECT LagerBew.BestandID, MAX(LagerBew.Zeitpunkt) AS Zeitpunkt
        FROM LagerBew
        WHERE LagerBew.Zeitpunkt < N'2019-04-01 00:00:00'
        GROUP BY LagerBew.BestandID
      ) AS LBZ ON LBZ.BestandID = LBID.BestandID AND LBZ.Zeitpunkt = LBID.Zeitpunkt
      GROUP BY LBID.BestandID
    ) AS LagerBewStichtag ON LagerBewStichtag.BestandID = LagerBew.BestandID AND LagerBewStichtag.ID = LagerBew.ID
  ) AS BestandStichtag ON BestandStichtag.BestandID = Bestand.ID
  WHERE BestandStichtag.BestandNeu > 0
    AND LagerArt.IstAnfLager = 0
),
Kundenbestand AS (
  SELECT DISTINCT Teile.ArtikelID
  FROM Teile
  WHERE Teile.Status IN (N'E', N'G', N'I', N'K', N'L', N'LM', N'M', N'N', N'O', N'Q', N'S', N'U', N'W')

  UNION

  SELECT DISTINCT KdArti.ArtikelID
  FROM VsaAnf
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  WHERE VsaAnf.BestandIst > 0
    AND VsaAnf.Status <> N'I'

  UNION

  SELECT DISTINCT KdArti.ArtikelID
  FROM VsaLeas
  JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
  WHERE VsaLeas.Menge > 0
    AND VsaLeas.AusDienst < (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat)
),
OffeneBestellung AS (
  SELECT DISTINCT ArtGroe.ArtikelID
  FROM BPo
  JOIN BKo ON BPo.BKoID = BKo.ID
  JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
  WHERE BKo.[Status] BETWEEN N'B' AND N'M'
    AND BPo.Menge > 0
    AND BKo.Datum < N'2019-04-01'
    AND (
      BPo.Menge > BPo.LiefMenge OR
      EXISTS (
        SELECT LiefLsPo.*
        FROM LiefLsPo
        JOIN LiefLsKo ON LiefLsPo.LiefLsKoID = LiefLsKo.ID
        WHERE LiefLsPo.BPoID = BPo.ID
          AND LiefLsPo.Menge > 0
          AND LiefLsKo.WeDatum >= N'2019-04-01'
      )
    )
)
SELECT Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  Artikelstatus.StatusBez AS Artikelstatus,
  Bereich.BereichBez AS Produktbereich,
  ArtGru.ArtGruBez AS Artikelgruppe,
  Lief.LiefNr,
  Lief.SuchCode AS Lieferant,
  Lief.Name1 AS [Lieferant-Zeile1],
  Lief.Name2 AS [Lieferant-Zeile2],
  Lief.Name3 AS [Lieferant-Zeile3],
  ArtiType.ArtiTypeBez AS Artikeltyp,
  CAST(IIF(Rechnungsartikel.ArtikelID IS NOT NULL, 1, 0) AS bit) AS [Artikel auf Rechnung],
  CAST(IIF(LieferscheinArtikel.ArtikelID IS NOT NULL, 1, 0) AS bit) AS [Artikel auf Lieferschein],
  CAST(IIF(Lagerbestand.ArtikelID IS NOT NULL, 1, 0) AS bit) AS [Artikel mit Lagerbestand],
  CAST(IIF(Kundenbestand.ArtikelID IS NOT NULL, 1, 0) AS bit) AS [Artikel bei Kunden],
  CAST(IIF(OffeneBestellung.ArtikelID IS NOT NULL, 1, 0) AS bit) AS [Artikel auf offener Bestellung]
FROM Artikel
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Lief ON Artikel.LiefID = Lief.ID
JOIN ArtiType ON Artikel.ArtiTypeID = ArtiType.ID
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
LEFT OUTER JOIN Rechnungsartikel ON Rechnungsartikel.ArtikelID = Artikel.ID
LEFT OUTER JOIN LieferscheinArtikel ON LieferscheinArtikel.ArtikelID = Artikel.ID
LEFT OUTER JOIN Lagerbestand ON Lagerbestand.ArtikelID = Artikel.ID
LEFT OUTER JOIN Kundenbestand ON Kundenbestand.ArtikelID = Artikel.ID
LEFT OUTER JOIN OffeneBestellung ON OffeneBestellung.ArtikelID = Artikel.ID
WHERE Artikel.ID > 0
  AND (Rechnungsartikel.ArtikelID IS NOT NULL OR Lagerbestand.ArtikelID IS NOT NULL OR Kundenbestand.ArtikelID IS NOT NULL OR OffeneBestellung.ArtikelID IS NOT NULL OR LieferscheinArtikel.ArtikelID IS NOT NULL);