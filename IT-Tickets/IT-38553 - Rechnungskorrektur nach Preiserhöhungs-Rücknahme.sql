-- Für diese Rechnungen müssen zuerst Gutschrift erstellt werden
SELECT RechKo.ID AS RechKoID, RechKo.RechNr, RechKo.RechDat
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE Kunden.KdNr = 271364
  AND RechKo.BasisRechKoID < 0
  AND RechKo.RechDat = N'2020-08-09';

-- Alle offenen Rechnungen auf abgeschlossen setzen (per Sammmeldruck), damit auf jeden Fall neue Rechnungen erzeugt werden und nicht mit bestehenden gemischt wird

UPDATE AbtKdArW SET RechPoID = -1, EPreis = KdArti.LeasingPreis, EPreisRech = KdArti.LeasingPreis, WoPa = AbtKdArW.Menge * KdArti.LeasingPreis
FROM AbtKdArW
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN KdArti ON AbtKdArW.KdArtiID = KdArti.ID
WHERE Kunden.KdNr = 271364
  AND Wochen.Woche BETWEEN N'2020/29' AND N'2020/32'
  AND AbtKdArW.EPreis != 0
  AND (AbtKdArW.RechPoID > 0 OR AbtKdArW.EPreis != KdArti.LeasingPreis OR (AbtKdArW.Menge * KdArti.LeasingPreis) != AbtKdArW.WoPa);

DECLARE @LsReset TABLE (
  LsKoID int,
  LsPoID int
);

INSERT INTO @LsReset (LsKoID, LsPoID)
SELECT LsKo.ID AS LsKoID, LsPo.ID AS LsPoID
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
WHERE Kunden.KdNr = 271364
  AND RechKo.RechDat = N'2020-08-09';

UPDATE LsPo SET RechPoID = -1
WHERE LsPo.ID IN (
  SELECT LsPoID FROM @LsReset
);

UPDATE LsKo SET [Status] = N'Q'
WHERE LsKo.ID IN (
  SELECT LskoID FROM @LsReset
);

UPDATE KdBer SET FakVonDat = N'2020-06-15', FakBisDat = N'2020-07-12'
WHERE KdBer.KundenID = (SELECT ID FROM Kunden WHERE KdNr = 271364);

UPDATE BrLauf SET LetzterLauf = N'2020-07-12' WHERE ID = 28;