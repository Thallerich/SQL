WITH WebVSA AS (
  SELECT Vsa.ID AS VsaID
  FROM Vsa
  WHERE Vsa.AbteilID IN (
      SELECT WebUAbt.AbteilID
      FROM WebUAbt
      JOIN Webuser ON WebUAbt.WebuserID = Webuser.ID
      WHERE Webuser.[Status] = N'A'
    )
    AND Vsa.ID IN (  
      SELECT Vsa.ID
      FROM Vsa
      JOIN WebUser ON WebUser.KundenID = Vsa.KundenID
      LEFT JOIN WebUVsa ON WebUVsa.WebUserID = WebUser.ID
      WHERE Webuser.[Status] = N'A'
        AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID)
    )
),
UHFVSA AS (
  SELECT VsaBer.VsaID
  FROM VsaBer
  JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
  WHERE (VsaBer.AnfAusEpo > 1 OR (VsaBer.AnfAusEpo = -1 AND KdBer.AnfAusEpo > 1))
)
SELECT KdGf.KurzBez AS Geschäftsbereich, ABC.ABCBez$LAN$ AS [ABC-Klasse], Holding.Holding, Standort.SuchCode AS Haupstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr], Vsa.Bez AS [VSA-Bezeichnung], CAST(IIF(WebVsa.VsaID IS NULL, 0, 1) AS bit) AS [Hat Webportal?], CAST(IIF(UHFVSA.VsaID IS NULL, 0, 1) AS bit) AS [UHF-Prozess?]
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
LEFT JOIN WebVSA ON WebVSA.VsaID = Vsa.ID
LEFT JOIN UHFVSA ON UHFVSA.VsaID = Vsa.ID
WHERE Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Vsa.[Status] = N'A'
ORDER BY KdNr, [VSA-Nr];