DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO VsaTexte (KundenID, VsaID, TextArtID, VonDatum, BisDatum, AnlageUserID_, UserID_, Memo)
SELECT Vsa.KundenID, Vsa.ID AS VsaID, CAST(2 AS int) AS TextArtID, DATEFROMPARTS(2023, 6, 7) AS VonDatum, DATEADD(week, 3, GETDATE()) AS BisDatum, @UserID AS AnlageUserID_, @UserID AS UserID_,
  Memo = CHAR(13) + CHAR(10) + N'Im Zuge unserer kontinuierlichen Optimierung der Produktionstechnik werden wir die Faltung der Handtücher auf eine effiziente Drittelfaltung umstellen.' + CHAR(13) + CHAR(10) + N'Wir sind zuversichtlich, dass diese Veränderung einen positiven Einfluss auf die Gesamtqualität unserer Dienstleistung haben wird.' + CHAR(13) + CHAR(10) + N'Diese Änderung erfolgt vor der Sommersaison innerhalb der nächsten beiden Wochen.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + N'Vielen Dank für Ihr Verständnis.'
FROM Vsa
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
WHERE StandBer.ProduktionID IN (SELECT ID FROM Standort WHERE SuchCode LIKE N'UKL_')
  AND KdBer.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'FW')
  AND VsaBer.[Status] = N'A'
  AND EXISTS (
    SELECT VsaTour.*
    FROM VsaTour
    WHERE VsaTour.VsaID = Vsa.ID
      AND VsaTour.KdBerID = KdBer.ID
      AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
  )
  AND Vsa.[Status] = N'A';

GO