WITH Bestellstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'BKO'
)
SELECT BKo.BestNr, BKo.[Status], Bestellstatus.StatusBez, BKo.BKoArtID, BKoArt.BkoartBez
FROM BKo
JOIN BKoArt ON BKo.BKoArtID = BKoArt.ID
JOIN Bestellstatus ON BKo.[Status] = Bestellstatus.[Status]
WHERE BKo.BestNr IN (412002809, 412002832, 412002824, 412001742);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ do stuff here                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

UPDATE BKo SET BKoArtID = 4 /* manuelle Bestellung */
WHERE BKo.BestNr IN (412002809, 412002832, 412002824, 412001742)
  AND BKo.BKoArtID = 9;