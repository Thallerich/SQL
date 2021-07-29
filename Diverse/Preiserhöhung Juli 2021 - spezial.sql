DELETE FROM PePo WHERE ID IN (
  SELECT PePo.ID
  FROM PeKo
  JOIN PePo ON PePo.PeKoID = PeKo.ID
  JOIN Vertrag ON PePo.VertragID = Vertrag.ID
  JOIN Kunden ON Vertrag.KundenID = Kunden.ID
  JOIN ABC ON Kunden.ABCID = ABC.ID
  WHERE PeKo.[Status] = N'C'
    AND Vertrag.PrLaufID = 1
);

GO

UPDATE PePo SET PePo.PeKoID = PeKoFix.ID
FROM PeKo
JOIN PePo ON PePo.PeKoID = PeKo.ID
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN PeKo AS PeKoFix ON Vertrag.PrLaufID = PeKoFix.PrLaufID AND LEFT(ABC.ABCBez, 1) = SUBSTRING(PeKofix.Bez, 28, 1)
WHERE PeKo.[Status] = N'C'
  AND PeKoFix.[Status] = N'C'
  AND Vertrag.PrLaufID != PeKo.PrLaufID
  AND NOT EXISTS (
    SELECT PePoCheck.*
    FROM PePo AS PePoCheck
    WHERE PePoCheck.PeKoID = PeKoFix.ID
      AND PePoCheck.VertragID = PePo.VertragID
  );

GO

DELETE FROM PePo WHERE ID IN (
  SELECT PePo.ID
  FROM PeKo
  JOIN PePo ON PePo.PeKoID = PeKo.ID
  JOIN Vertrag ON PePo.VertragID = Vertrag.ID
  JOIN Kunden ON Vertrag.KundenID = Kunden.ID
  JOIN ABC ON Kunden.ABCID = ABC.ID
  WHERE PeKo.[Status] = N'C'
    AND Vertrag.PrLaufID != PeKo.PrLaufID
);

GO

UPDATE PeKo SET AnzVertraege = x.Anz
FROM PeKo
JOIN (
  SELECT PePo.PeKoID, COUNT(DISTINCT PePo.VertragID) AS Anz
  FROM PePo
  GROUP BY PePo.PeKoID
) AS x ON x.PeKoID = PeKo.ID
WHERE PeKo.[Status] = N'C';

GO