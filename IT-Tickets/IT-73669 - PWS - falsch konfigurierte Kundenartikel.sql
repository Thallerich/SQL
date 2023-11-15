DECLARE @kdgfid int = (SELECT KdGf.ID FROM KdGf WHERE KdGf.KurzBez = N'MED');

DECLARE @Hauptstandort TABLE (
  StandortID int,
  StandortKuerzel nchar(4) COLLATE Latin1_General_CS_AS
);

INSERT INTO @Hauptstandort (StandortKuerzel)
VALUES (N'WOEN'), (N'WOLI');

UPDATE @Hauptstandort SET StandortID = Standort.ID
FROM Standort
WHERE Standort.SuchCode = [@Hauptstandort].StandortKuerzel;

WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS Kundenstatus, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Eigentum.EigentumBez AS Eigentumsverhältnis
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN Eigentum ON KdArti.EigentumID = Eigentum.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
WHERE Kunden.KdGFID = @kdgfid
  AND Kunden.StandortID IN (SELECT StandortID FROM @Hauptstandort)
  AND Eigentum.RueckgabeBew = 1
  AND Bereich.Bereich = N'PWS'
  AND ArtGru.Sack = 0
  AND Kunden.AdrArtID = 1
  AND EXISTS (
    SELECT EinzHist.*
    FROM EinzHist
    JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
    WHERE EinzHist.KdArtiID = KdArti.ID
      AND EinzTeil.AltenheimModus = 1
  );

GO