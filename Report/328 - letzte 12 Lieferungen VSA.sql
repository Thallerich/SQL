-- Liefertage:
SELECT
  MAX(CASE LiefTag WHEN 1 THEN Datum END) as d1,
  MAX(CASE LiefTag WHEN 2 THEN Datum END) as d2,
  MAX(CASE LiefTag WHEN 3 THEN Datum END) as d3,
  MAX(CASE LiefTag WHEN 4 THEN Datum END) as d4,
  MAX(CASE LiefTag WHEN 5 THEN Datum END) as d5,
  MAX(CASE LiefTag WHEN 6 THEN Datum END) as d6,
  MAX(CASE LiefTag WHEN 7 THEN Datum END) as d7,
  MAX(CASE LiefTag WHEN 8 THEN Datum END) as d8,
  MAX(CASE LiefTag WHEN 9 THEN Datum END) as d9,
  MAX(CASE LiefTag WHEN 10 THEN Datum END) as d10,
  MAX(CASE LiefTag WHEN 11 THEN Datum END) as d11,
  MAX(CASE LiefTag WHEN 12 THEN Datum END) as d12
FROM (
  SELECT COUNT(*) AS LiefTag, a.Datum
  FROM (
    SELECT DISTINCT TOP 12 Datum
    FROM LsKo, VSA, Kunden
    WHERE VSA.ID = LsKo.VSAID
      AND Kunden.ID = VSA.KundenID
      AND VSA.ID = $ID$
      AND Datum <= $1$
    ORDER BY Datum DESC
  ) a, (
    SELECT DISTINCT TOP 12 Datum
    FROM LsKo, VSA, Kunden
    WHERE VSA.ID = LsKo.VSAID
     AND Kunden.ID = VSA.KundenID
     AND VSA.ID = $ID$
     AND Datum <= $1$
    ORDER BY Datum DESC
  ) b
  WHERE a.Datum >= b.Datum GROUP BY a.Datum
) c;

--Lieferungen:
SELECT KdNr, Name1, ArtikelNr, ArtikelBez, SuchCode,
  SUM(CASE LiefTag WHEN 1 THEN Menge END) as a,
  SUM(CASE LiefTag WHEN 2 THEN Menge END) as b,
  SUM(CASE LiefTag WHEN 3 THEN Menge END) as c,
  SUM(CASE LiefTag WHEN 4 THEN Menge END) as d,
  SUM(CASE LiefTag WHEN 5 THEN Menge END) as e,
  SUM(CASE LiefTag WHEN 6 THEN Menge END) as f,
  SUM(CASE LiefTag WHEN 7 THEN Menge END) as g,
  SUM(CASE LiefTag WHEN 8 THEN Menge END) as h,
  SUM(CASE LiefTag WHEN 9 THEN Menge END) as i,
  SUM(CASE LiefTag WHEN 10 THEN Menge END) as j,
  SUM(CASE LiefTag WHEN 11 THEN Menge END) as k,
  SUM(CASE LiefTag WHEN 12 THEN Menge END) as l,
  SUM(Menge) as Summe,
  SUM(Menge)/12 as Durchschnitt,
  MAX(CASE LiefTag WHEN 1 THEN Datum END) as d1,
  MAX(CASE LiefTag WHEN 2 THEN Datum END) as d2,
  MAX(CASE LiefTag WHEN 3 THEN Datum END) as d3,
  MAX(CASE LiefTag WHEN 4 THEN Datum END) as d4,
  MAX(CASE LiefTag WHEN 5 THEN Datum END) as d5,
  MAX(CASE LiefTag WHEN 6 THEN Datum END) as d6,
  MAX(CASE LiefTag WHEN 7 THEN Datum END) as d7,
  MAX(CASE LiefTag WHEN 8 THEN Datum END) as d8,
  MAX(CASE LiefTag WHEN 9 THEN Datum END) as d9,
  MAX(CASE LiefTag WHEN 10 THEN Datum END) as d10,
  MAX(CASE LiefTag WHEN 11 THEN Datum END) as d11,
  MAX(CASE LiefTag WHEN 12 THEN Datum END) as d12
FROM (
  SELECT a.LiefTag, a.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, LsPo.Menge, VSA.SuchCode, KdNr, Kunden.Name1
  FROM LsKo, VSA, Kunden, (
    SELECT count(*) as LiefTag, a.Datum
    FROM (
      SELECT DISTINCT TOP 12 Datum
      FROM LsKo, VSA, Kunden
      WHERE VSA.ID=LsKo.VSAID
        AND Kunden.ID=VSA.KundenID
        AND VSA.ID=$ID$
        AND Datum <= $1$
      ORDER BY Datum DESC
    ) a, (
      SELECT DISTINCT TOP 12 Datum
      FROM LsKo, VSA, Kunden
      WHERE VSA.ID=LsKo.VSAID
        AND Kunden.ID=VSA.KundenID
        AND VSA.ID=$ID$
        AND Datum <= $1$
      ORDER BY Datum DESC
    ) b
    WHERE a.Datum >= b.Datum
    GROUP BY a.Datum
  ) a, LsPo, KdArti, Artikel
  WHERE KdArti.ID=LsPo.KdArtiID
    AND Artikel.ID=KdArti.ArtikelID
    AND LsPo.LsKoID=LsKo.ID
    AND VSA.ID=LsKo.VSAID
    AND Kunden.ID=VSA.KundenID
    AND VSA.ID=$ID$
    AND a.Datum=LsKo.Datum
) c
GROUP BY ArtikelNr, ArtikelBez, SuchCode, KdNr, Name1
ORDER BY SuchCode, ArtikelNr;
