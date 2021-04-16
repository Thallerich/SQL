DECLARE @LieferInfo TABLE (
  VsaID int,
  ArtGroeID int,
  KdArtiID int,
  KdBerID int,
  AnfArt nchar(1),
  NormMenge numeric(18,4),
  Montag numeric(18,4),
  Dienstag numeric(18,4),
  Mittwoch numeric(18,4),
  Donnerstag numeric(18,4),
  Freitag numeric(18,4),
  Samstag numeric(18,4),
  Sonntag numeric(18,4),
  Vertragsbestand int
);

INSERT INTO @LieferInfo (VsaID, ArtGroeID, KdArtiID, KdBerID, AnfArt, NormMenge, Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag, Sonntag, Vertragsbestand)
SELECT VsaAnf.VsaID, VsaAnf.ArtGroeID, VsaAnf.KdArtiID, KdArti.KdBerID, VsaAnf.Art AS AnfArt, VsaAnf.NormMenge, VsaAnf.Liefern1 AS Montag, VsaAnf.Liefern2 AS Dienstag, VsaAnf.Liefern3 AS Mittwoch, VsaAnf.Liefern4 AS Donnerstag, VsaAnf.Liefern5 AS Freitag, VsaAnf.Liefern6 AS Samstag, VsaAnf.Liefern7 AS Sonntag, VsaAnf.Bestand AS Vertragsbestand
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
WHERE Kunden.ID = $ID$
  AND Vsa.Status = N'A'
  AND VsaAnf.Status < N'E';

WITH VsaLiefTag AS (
  SELECT VsaID, KdBerID, ISNULL([1], 0) AS Montag, ISNULL([2], 0) AS Dienstag, ISNULL([3], 0) AS Mittwoch, ISNULL([4], 0) AS Donnerstag, ISNULL([5], 0) AS Freitag, ISNULL([6], 0) AS Samstag, ISNULL([7], 0) AS Sonntag
  FROM (
    SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Wochentag, CAST(1 AS tinyint) AS IsLiefertag
    FROM VsaTour
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    WHERE CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND VsaTour.Bringen = 1
  ) AS Liefertag
  PIVOT (
    MAX(IsLiefertag) FOR Wochentag IN ([1], [2], [3], [4], [5], [6], [7])
  ) AS PivotLiefertag
)
UPDATE LieferInfo
  SET Montag = IIF(VsaLiefTag.Montag = 1, LieferInfo.Montag, 0),
      Dienstag = IIF(VsaLiefTag.Dienstag = 1, LieferInfo.Dienstag, 0),
      Mittwoch = IIF(VsaLiefTag.Mittwoch = 1, LieferInfo.Mittwoch, 0),
      Donnerstag = IIF(VsaLiefTag.Donnerstag = 1, LieferInfo.Donnerstag, 0),
      Freitag = IIF(VsaLiefTag.Freitag = 1, LieferInfo.Freitag, 0),
      Samstag = IIF(VsaLiefTag.Samstag = 1, LieferInfo.Samstag, 0),
      Sonntag = IIF(VsaLiefTag.Sonntag = 1, LieferInfo.Sonntag, 0)
FROM @LieferInfo AS LieferInfo
LEFT JOIN VsaLiefTag ON LieferInfo.VsaID = VsaLiefTag.VsaID AND LieferInfo.KdBerID = VsaLiefTag.KdBerID
WHERE LieferInfo.AnfArt = N'F';

UPDATE @LieferInfo SET NormMenge = 0
WHERE AnfArt != N'N';

UPDATE @LieferInfo SET Montag = 0, Dienstag = 0, Mittwoch = 0, Donnerstag = 0, Freitag = 0, Samstag = 0, Sonntag = 0
WHERE AnfArt != N'F';

SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr AS [VSA-Nummer],
  Vsa.Bez AS [VSA-Bezeichnung],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS [Größe],
  Art = CASE UPPER(LieferInfo.AnfArt)
      WHEN N'F' THEN N'feste Liefermenge'
      WHEN N'N' THEN N'Norm-Liefermenge'
      WHEN N'X' THEN N'Min/Max-Belieferung'
      WHEN N'V' THEN N'Vertragsbestandsanpassung'
      ELSE N'manuelle Anforderung'
    END,
  LieferInfo.NormMenge AS [Norm-Liefermenge],
  LieferInfo.Montag,
  LieferInfo.Dienstag,
  LieferInfo.Mittwoch,
  LieferInfo.Donnerstag,
  LieferInfo.Freitag,
  LieferInfo.Samstag,
  LieferInfo.Sonntag,
  LieferInfo.Vertragsbestand
FROM @LieferInfo AS LieferInfo
JOIN Vsa ON LieferInfo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON LieferInfo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON LieferInfo.ArtGroeID = ArtGroe.ID
JOIN GroePo ON ArtGroe.Groesse = GroePo.Groesse AND Artikel.GroeKoID = GroePo.GroeKoID
WHERE LieferInfo.NormMenge != 0
  OR LieferInfo.Montag != 0
  OR LieferInfo.Dienstag != 0
  OR LieferInfo.Mittwoch != 0
  OR LieferInfo.Donnerstag != 0
  OR LieferInfo.Freitag != 0
  OR LieferInfo.Samstag != 0
  OR LieferInfo.Sonntag != 0
  OR LieferInfo.Vertragsbestand != 0
ORDER BY KdNr, [VSA-Nummer], ArtikelNr, GroePo.Folge;