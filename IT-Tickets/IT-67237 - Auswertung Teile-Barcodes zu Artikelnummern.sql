DECLARE @Article TABLE (
  ArticleNumber nchar(15) COLLATE Latin1_General_CS_AS PRIMARY KEY NOT NULL
);

INSERT INTO @Article (ArticleNumber)
VALUES (N'3010000000'), (N'3010000001'), (N'98VO'), (N'VWGB'), (N'3022804001'), (N'VGDF'), (N'2504000039'), (N'3032804001'), (N'3630010186'), (N'V7GB'), (N'4007030001'), (N'VGGB'), (N'3012804001'), (N'V3GB'), (N'V5SI'), (N'2504000038'), (N'2504000036'), (N'V3DF'), (N'V7DF'), (N'V6DF'), (N'VGIB'), (N'VWIB'), (N'VWDF'), (N'V7IB'), (N'V5DF'), (N'V4DF'), (N'V6IB'), (N'V6GB'), (N'6006030001'), (N'V3IB'), (N'V5IM'), (N'V5GB'), (N'V4GB'), (N'TSVO'), (N'V4IB'), (N'V5IB'), (N'98VY'), (N'TSVY');

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
),
Traegerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TRAEGER'
),
Vsastatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VSA'
),
Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status Kunde], Vsa.VsaNr, Vsa.Bez AS [VSA-Bezeichnung], Vsastatus.StatusBez AS [Status VSA], Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Traegerstatus.StatusBez AS [Status Träger], EinzHist.Barcode, Teilestatus.StatusBez AS [Status Barcode], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, EinzHist.RuecklaufG AS [Waschzyklen gesamt], EinzHist.RuecklaufK AS [Waschzyklen aktueller Träger], EinzHist.AnzRepairG AS [Reparaturen gesamt], EinzHist.AnzRepair AS [Reparaturen aktueller Träger], Produktion.SuchCode AS Produktion, Produktion.Bez AS [Produktions-Standort]
FROM EinzHist
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
JOIN Traegerstatus ON Traeger.[Status] = Traegerstatus.[Status]
JOIN Vsastatus ON Vsa.[Status] = Vsastatus.[Status]
JOIN Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
WHERE Artikel.ArtikelNr IN (SELECT ArticleNumber FROM @Article)
  AND GETDATE() BETWEEN EinzHist.EinzHistVon AND EinzHist.EinzHistBis
  AND EinzHist.PoolFkt = 0
  AND EinzHist.IsCurrEinzHist = 1
  AND EinzHist.Archiv = 0
  AND (EinzHist.Status BETWEEN N'N' AND N'XI' OR EinzHist.Status = N'Z');

GO