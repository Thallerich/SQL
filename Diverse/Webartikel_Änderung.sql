UPDATE KdArti SET KdArti.WebArtikel = $FALSE$
WHERE KdArti.ID IN (
  SELECT KdArti.ID
  FROM KdArti, Kunden, KdBer, Bereich
  WHERE KdArti.KundenID = Kunden.ID
    AND Kunden.KdNr IN (2300, 2301, 6071, 7240, 9013, 11049, 11050, 18029, 19010, 19013, 19015, 19023, 19024, 19129, 20000, 20124, 20125, 20142, 20143, 20150, 23032, 23037, 23042, 23046, 23047, 23048, 24045, 25000, 25004, 25005, 26010)
    AND KdArti.Vertragsartikel = $FALSE$
    AND KdArti.WebArtikel = $TRUE$
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID = Bereich.ID
    AND Bereich.Bereich IN ('SH', 'TW', 'FWL', 'IK')
);

UPDATE KdArti SET KdArti.WebArtikel = $TRUE$
WHERE KdArti.ID IN (
  SELECT KdArti.ID
  FROM KdArti, Kunden, KdBer.Bereich
  WHERE KdArti.KundenID = Kunden.ID
    AND Kunden.KdNr IN (2300, 2301, 6071, 7240, 9013, 11049, 11050, 18029, 19010, 19013, 19015, 19023, 19024, 19129, 20000, 20124, 20125, 20142, 20143, 20150, 23032, 23037, 23042, 23046, 23047, 23048, 24045, 25000, 25004, 25005, 26010)
    AND KdArti.Vertragsartikel = $TRUE$
    AND KdArti.WebArtikel = $FALSE$
    AND KdBer.BereichID = Bereich.ID
    AND Bereich.Bereich IN ('SH', 'TW', 'FWL', 'IK')
);