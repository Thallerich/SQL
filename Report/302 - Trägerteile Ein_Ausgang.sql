SELECT * FROM (
  SELECT KdNr, Name1, SuchCode, Barcode, ArtikelNr, ArtikelBez, Traeger,
    SUM(CASE EingAusg WHEN 'Eingang' Then 1 END) as Eingänge,
    SUM(CASE EingAusg WHEN 'Ausgang' Then 1 END) as Ausgänge,
    MAX(CASE EinAus WHEN 'Eingang1' Then EinAusDat END) as Eingang1,
    MAX(CASE EinAus WHEN 'Eingang2' Then EinAusDat END) as Eingang2,
    MAX(CASE EinAus WHEN 'Eingang3' Then EinAusDat END) as Eingang3,
    MAX(CASE EinAus WHEN 'Eingang4' Then EinAusDat END) as Eingang4,
    MAX(CASE EinAus WHEN 'Eingang5' Then EinAusDat END) as Eingang5,
    MAX(CASE EinAus WHEN 'Eingang6' Then EinAusDat END) as Eingang6,
    MAX(CASE EinAus WHEN 'Eingang7' Then EinAusDat END) as Eingang7,
    MAX(CASE EinAus WHEN 'Eingang8' Then EinAusDat END) as Eingang8,
    MAX(CASE EinAus WHEN 'Eingang9' Then EinAusDat END) as Eingang9,
    MAX(CASE EinAus WHEN 'Eingang10' Then EinAusDat END) as Eingang10,
    MAX(CASE EinAus WHEN 'Eingang11' Then EinAusDat END) as Eingang11,
    MAX(CASE EinAus WHEN 'Eingang12' Then EinAusDat END) as Eingang12,
    MAX(CASE EinAus WHEN 'Eingang13' Then EinAusDat END) as Eingang13,
    MAX(CASE EinAus WHEN 'Eingang14' Then EinAusDat END) as Eingang14,
    MAX(CASE EinAus WHEN 'Eingang15' Then EinAusDat END) as Eingang15,
    MAX(CASE EinAus WHEN 'Eingang16' Then EinAusDat END) as Eingang16,
    MAX(CASE EinAus WHEN 'Eingang17' Then EinAusDat END) as Eingang17,
    MAX(CASE EinAus WHEN 'Eingang18' Then EinAusDat END) as Eingang18,
    MAX(CASE EinAus WHEN 'Eingang18' Then EinAusDat END) as Eingang19,
    MAX(CASE EinAus WHEN 'Eingang18' Then EinAusDat END) as Eingang20,
    MAX(CASE EinAus WHEN 'Ausgang1' Then EinAusDat END) as Ausgang1,
    MAX(CASE EinAus WHEN 'Ausgang2' Then EinAusDat END) as Ausgang2,
    MAX(CASE EinAus WHEN 'Ausgang3' Then EinAusDat END) as Ausgang3,
    MAX(CASE EinAus WHEN 'Ausgang4' Then EinAusDat END) as Ausgang4,
    MAX(CASE EinAus WHEN 'Ausgang5' Then EinAusDat END) as Ausgang5,
    MAX(CASE EinAus WHEN 'Ausgang6' Then EinAusDat END) as Ausgang6,
    MAX(CASE EinAus WHEN 'Ausgang7' Then EinAusDat END) as Ausgang7,
    MAX(CASE EinAus WHEN 'Ausgang8' Then EinAusDat END) as Ausgang8,
    MAX(CASE EinAus WHEN 'Ausgang9' Then EinAusDat END) as Ausgang9,
    MAX(CASE EinAus WHEN 'Ausgang10' Then EinAusDat END) as Ausgang10,
    MAX(CASE EinAus WHEN 'Ausgang11' Then EinAusDat END) as Ausgang11,
    MAX(CASE EinAus WHEN 'Ausgang12' Then EinAusDat END) as Ausgang12,
    MAX(CASE EinAus WHEN 'Ausgang13' Then EinAusDat END) as Ausgang13,
    MAX(CASE EinAus WHEN 'Ausgang14' Then EinAusDat END) as Ausgang14,
    MAX(CASE EinAus WHEN 'Ausgang15' Then EinAusDat END) as Ausgang15,
    MAX(CASE EinAus WHEN 'Ausgang16' Then EinAusDat END) as Ausgang16,
    MAX(CASE EinAus WHEN 'Ausgang17' Then EinAusDat END) as Ausgang17,
    MAX(CASE EinAus WHEN 'Ausgang18' Then EinAusDat END) as Ausgang18,
    MAX(CASE EinAus WHEN 'Ausgang19' Then EinAusDat END) as Ausgang19,
    MAX(CASE EinAus WHEN 'Ausgang20' Then EinAusDat END) as Ausgang20
  FROM (
    SELECT a.KdNr, a.Name1, a.SuchCode, a.Barcode, a.ArtikelNr, a.ArtikelBez, a.Traeger, a.EinAusDat, a.EinAus+convert(char(5), count(*)) as EinAus, a.EinAus as EingAusg
    FROM (
      SELECT Kunden.KdNr, Kunden.Name1, VSA.SuchCode, S.Menge, S.ID, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, RTRIM(Nachname)+' '+RTRIM(Vorname) as Traeger, S.EinAusDat, CASE S.Menge WHEN 1 THEN 'Eingang' ELSE 'Ausgang' END as EinAus
      FROM Traeger, VSA, Kunden, Teile, Artikel, Scans as S
      WHERE S.TeileID=Teile.ID
        AND Artikel.ID=Teile.ArtikelID
        AND Teile.TraegerID=Traeger.ID
        AND Traeger.VSAID=VSA.ID
        AND Kunden.ID=VSA.KundenID
        AND Kunden.ID=$ID$
        AND S.Menge=1
        AND EinAusDat BETWEEN $1$ AND $2$
    ) a, (
      SELECT Kunden.KdNr, Kunden.Name1, VSA.SuchCode, S.Menge, S.ID, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, RTRIM(Nachname)+' '+RTRIM(Vorname) as Traeger, S.EinAusDat, CASE S.Menge WHEN 1 THEN 'Eingang' ELSE 'Ausgang' END as EinAus
      FROM Traeger, VSA, Kunden, Teile, Artikel, Scans as S
      WHERE S.TeileID=Teile.ID
        AND Artikel.ID=Teile.ArtikelID
        AND Teile.TraegerID=Traeger.ID
        AND Traeger.VSAID=VSA.ID
        AND Kunden.ID=VSA.KundenID
        AND Kunden.ID=$ID$
        AND S.Menge=1
        AND EinAusDat BETWEEN $1$ AND $2$
    ) b
    WHERE a.Barcode=b.Barcode and a.ID>=b.ID
    GROUP BY a.KdNr, a.Name1, a.SuchCode, a.ID, a.Barcode, a.ArtikelNr, a.ArtikelBez, a.Traeger, a.EinAusDat, a.EinAus

    UNION

    SELECT a.KdNr, a.Name1, a.SuchCode, a.Barcode, a.ArtikelNr, a.ArtikelBez, a.Traeger, a.EinAusDat, a.EinAus+convert(char(5), count(*)) as EinAus, a.EinAus as EingAusg
    FROM (
      SELECT Kunden.KdNr, Kunden.Name1, VSA.SuchCode, S.Menge, S.ID, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, RTRIM(Nachname)+' '+RTRIM(Vorname) as Traeger, S.EinAusDat, CASE S.Menge WHEN 1 THEN 'Eingang' ELSE 'Ausgang' END as EinAus
      FROM Traeger, VSA, Kunden, Teile, Artikel, Scans as S
      WHERE S.TeileID=Teile.ID
        AND Artikel.ID=Teile.ArtikelID
        AND Teile.TraegerID=Traeger.ID
        AND Traeger.VSAID=VSA.ID
        AND Kunden.ID=VSA.KundenID
        AND Kunden.ID=$ID$
        AND S.Menge=-1
        AND EinAusDat BETWEEN $1$ AND $2$
    ) a, (
      SELECT Kunden.KdNr, Kunden.Name1, VSA.SuchCode, S.Menge, S.ID, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, RTRIM(Nachname)+' '+RTRIM(Vorname) as Traeger, S.EinAusDat, CASE S.Menge WHEN 1 THEN 'Eingang' ELSE 'Ausgang' END as EinAus
      FROM Traeger, VSA, Kunden, Teile, Artikel, Scans as S
      WHERE S.TeileID=Teile.ID
        AND Artikel.ID=Teile.ArtikelID
        AND Teile.TraegerID=Traeger.ID
        AND Traeger.VSAID=VSA.ID
        AND Kunden.ID=VSA.KundenID
        AND Kunden.ID=$ID$
        AND S.Menge=-1
        AND EinAusDat BETWEEN $1$ AND $2$
    ) b
    WHERE a.Barcode=b.Barcode
      AND a.ID>=b.ID
    GROUP BY a.KdNr, a.Name1, a.SuchCode, a.ID, a.Barcode, a.ArtikelNr, a.ArtikelBez, a.Traeger, a.EinAusDat, a.EinAus
  ) a
GROUP BY KdNr, Name1, SuchCode, Barcode, ArtikelNr, ArtikelBez, Traeger
) x
ORDER BY SuchCode, Traeger, ArtikelNr