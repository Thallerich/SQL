-- #########################################################################
-- Pipeline: Liefertage
-- #########################################################################

SELECT
MAX(CASE LiefTag WHEN 1 THEN Datum END) AS d1,
MAX(CASE LiefTag WHEN 2 THEN Datum END) AS d2,
MAX(CASE LiefTag WHEN 3 THEN Datum END) AS d3,
MAX(CASE LiefTag WHEN 4 THEN Datum END) AS d4,
MAX(CASE LiefTag WHEN 5 THEN Datum END) AS d5,
MAX(CASE LiefTag WHEN 6 THEN Datum END) AS d6,
MAX(CASE LiefTag WHEN 7 THEN Datum END) AS d7,
MAX(CASE LiefTag WHEN 8 THEN Datum END) AS d8,
MAX(CASE LiefTag WHEN 9 THEN Datum END) AS d9,
MAX(CASE LiefTag WHEN 10 THEN Datum END) AS d10,
MAX(CASE LiefTag WHEN 11 THEN Datum END) AS d11,
MAX(CASE LiefTag WHEN 12 THEN Datum END) AS d12
FROM (
  SELECT COUNT(*) AS LiefTag, a.Datum
  FROM (
    SELECT DISTINCT TOP 12 LsKo.Datum
    FROM LsKo, Vsa, Kunden
    WHERE Vsa.ID = LsKo.VsaID
      AND Kunden.ID = Vsa.KundenID
      AND Kunden.ID = $ID$
      AND LsKo.Datum <= $1$
    ORDER BY LsKo.Datum DESC
  ) a, (
    SELECT DISTINCT TOP 12 LsKo.Datum
    FROM LsKo, Vsa, Kunden
    WHERE Vsa.ID = LsKo.VsaID
      AND Kunden.ID = Vsa.KundenID
      AND Kunden.ID = $ID$
      AND LsKo.Datum <= $1$
    ORDER BY LsKo.Datum DESC
  ) b
  WHERE a.Datum >= b.Datum
  GROUP BY a.Datum
) c;

-- #########################################################################
-- Pipeline: Liefertage
-- #########################################################################

SELECT KdNr, Name1, ArtikelNr, ArtikelBez, SuchCode,
SUM(CASE LiefTag WHEN 1 THEN Menge END) AS a,
SUM(CASE LiefTag WHEN 2 THEN Menge END) AS b,
SUM(CASE LiefTag WHEN 3 THEN Menge END) AS c,
SUM(CASE LiefTag WHEN 4 THEN Menge END) AS d,
SUM(CASE LiefTag WHEN 5 THEN Menge END) AS e,
SUM(CASE LiefTag WHEN 6 THEN Menge END) AS f,
SUM(CASE LiefTag WHEN 7 THEN Menge END) AS g,
SUM(CASE LiefTag WHEN 8 THEN Menge END) AS h,
SUM(CASE LiefTag WHEN 9 THEN Menge END) AS i,
SUM(CASE LiefTag WHEN 10 THEN Menge END) AS j,
SUM(CASE LiefTag WHEN 11 THEN Menge END) AS k,
SUM(CASE LiefTag WHEN 12 THEN Menge END) AS l,
MAX(CASE LiefTag WHEN 1 THEN Datum END) AS d1,
MAX(CASE LiefTag WHEN 2 THEN Datum END) AS d2,
MAX(CASE LiefTag WHEN 3 THEN Datum END) AS d3,
MAX(CASE LiefTag WHEN 4 THEN Datum END) AS d4,
MAX(CASE LiefTag WHEN 5 THEN Datum END) AS d5,
MAX(CASE LiefTag WHEN 6 THEN Datum END) AS d6,
MAX(CASE LiefTag WHEN 7 THEN Datum END) AS d7,
MAX(CASE LiefTag WHEN 8 THEN Datum END) AS d8,
MAX(CASE LiefTag WHEN 9 THEN Datum END) AS d9,
MAX(CASE LiefTag WHEN 10 THEN Datum END) AS d10,
MAX(CASE LiefTag WHEN 11 THEN Datum END) AS d11,
MAX(CASE LiefTag WHEN 12 THEN Datum END) AS d12
FROM (
  SELECT a.LiefTag, a.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, LsPo.Menge, Vsa.SuchCode, Kunden.KdNr, Kunden.Name1
  FROM LsKo, Vsa, Kunden, (
    SELECT count(*) AS LiefTag, a.Datum
    FROM (
      SELECT DISTINCT TOP 12 LsKo.Datum
      FROM LsKo, Vsa, Kunden
      WHERE Vsa.ID = LsKo.VsaID
        and Kunden.ID = Vsa.KundenID
        and Kunden.ID = $ID$
        and Datum <= $1$
      ORDER BY LsKo.Datum DESC
    ) a, (
      SELECT DISTINCT TOP 12 LsKo.Datum
      FROM LsKo, Vsa, Kunden
      WHERE Vsa.ID = LsKo.VsaID
        and Kunden.ID = Vsa.KundenID
        and Kunden.ID = $ID$
        and Datum <= $1$
      ORDER BY LsKo.Datum DESC
    ) b
    WHERE a.Datum >= b.Datum
    GROUP BY a.Datum
  ) a, LsPo, KdArti, Artikel
  WHERE KdArti.ID = LsPo.KdArtiID
    and Artikel.ID = KdArti.ArtikelID
    and LsPo.LsKoID = LsKo.ID
    and Vsa.ID = LsKo.VsaID
    and Kunden.ID = VSA.KundenID
    and Kunden.ID = $ID$
    and a.Datum = LsKo.Datum
  ) c
GROUP BY ArtikelNr, ArtikelBez, SuchCode, KdNr, Name1
ORDER BY SuchCode, ArtikelNr;