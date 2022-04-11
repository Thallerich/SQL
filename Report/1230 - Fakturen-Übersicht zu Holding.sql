DECLARE @RechVon date = $2$;
DECLARE @RechBis date = $3$;

WITH Liefermenge AS (
  SELECT Vsa.KundenID, KdArti.ArtikelID, KdArti.Variante, LsPo.AbteilID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  WHERE LsPo.RechPoID IN (
    SELECT RechPo.ID
    FROM RechPo
    JOIN RechKo ON RechPo.RechKoID = RechKo.ID
    JOIN Kunden ON RechKo.KundenID = Kunden.ID
    WHERE Kunden.HoldingID IN ($1$)
      AND RechKo.RechDat BETWEEN @RechVon AND @RechBis
  )
  GROUP BY Vsa.KundenID, KdArti.ArtikelID, KdArti.Variante, LsPo.AbteilID
)
SELECT Kunden.Debitor, Kunden.KdNr, Kunden.SuchCode AS Kunde, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, Bereich.Bereich AS Aktivität, ArtGru.Gruppe AS Produktgruppe, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, KdArti.WaschPreis AS [Preis Waschen], KdArti.LeasPreis AS [Preis Miete], RechPo.EPreis AS [Preis Rechnung], Liefermenge.Liefermenge, SUM(RechPo.Menge) AS [fakturierte Menge], SUM(RechPo.GPreis) AS Umsatz, IIF(RechKo.Art = N'G', N'Gutschrift', N'Rechnung') AS Rechnungstyp, FORMAT(RechKo.RechDat, N'yyyy.MM', N'de-AT') AS [Jahr.Monat]
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Bereich ON RechPo.BereichID = Bereich.ID
LEFT OUTER JOIN Liefermenge ON Liefermenge.KundenID = Kunden.ID AND Liefermenge.ArtikelID = Artikel.ID AND Liefermenge.Variante = KdArti.Variante AND Liefermenge.AbteilID = Abteil.ID
WHERE Kunden.HoldingID IN ($1$)
  AND RechKo.RechDat BETWEEN @RechVon AND @RechBis
  AND RechPo.KdArtiID > 0
GROUP BY Kunden.Debitor, Kunden.KdNr, Kunden.SuchCode, Abteil.Abteilung, Abteil.Bez, Bereich.Bereich, ArtGru.Gruppe, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, KdArti.Variante, KdArti.WaschPreis, KdArti.LeasPreis, RechPo.EPreis, Liefermenge.Liefermenge, RechKo.Art, FORMAT(RechKo.RechDat, N'yyyy.MM', N'de-AT');