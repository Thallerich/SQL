DECLARE @dosomething bit;

SET @dosomething = (SELECT IIF(AnfKo.Status > 'I', 1, 0) FROM AnfKo WHERE AnfKo.AuftragsNr = $1$);

UPDATE KdArti SET KdArti.LsAusblenden = $TRUE$
WHERE KdArti.ID IN (
  SELECT KdArti.ID
  FROM AnfPo, AnfKo, KdArti
  WHERE AnfPo.AnfKoID = AnfKo.ID
    AND AnfPo.KdArtiID = KdArti.ID
    AND AnfKo.AuftragsNr = $1$
    AND KdArti.Vertragsartikel = $FALSE$
    AND KdArti.LsAusblenden = $FALSE$
  )
  AND @dosomething = 1;

UPDATE AnfKo SET AnfKo.LsKoMemo = NULL
WHERE AnfKo.AuftragsNr = $1$
  AND AnfKo.LsKoMemo LIKE '%einbehalten%'
  AND @dosomething = 1;

SELECT IIF(@dosomething = 1, 'Nicht-Vertragsartikel vom Lieferschein zum Packzettel ' + $1$ + ' entfernt!', 'Packzettel ' + $1$ + ' noch nicht fertig verarbeitet!') AS Message;