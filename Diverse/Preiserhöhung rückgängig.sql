DECLARE @PeBack TABLE (
  KdArtiID int,
  WaschPreis money,
  LeasPreis money,
  VkPreis money,
  SonderPreis money,
  LeasPreisAbwAbWo money,
  BasisRestwert money,
  PePoID int
);

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @PeKoID int = 679;

WITH LastPrArchiv AS (
  SELECT PrArchiv.KdArtiID, MAX(PrArchiv.ID) AS PrArchivID
  FROM PrArchiv
  WHERE PrArchiv.PeKoID != @PeKoID
  GROUP BY PrArchiv.KdArtiID
)
UPDATE KdArti SET WaschPreis = PrArchiv.WaschPreis, LeasPreis = PrArchiv.LeasPreis, VkPreis = PrArchiv.VKPreis, SonderPreis = PrArchiv.SonderPreis, LeasPreisAbwAbWo = PrArchiv.LeasPreisAbwAbWo, BasisRestwert = PrArchiv.BasisRestwert
OUTPUT inserted.ID, inserted.WaschPreis, inserted.LeasPreis, inserted.VkPreis, inserted.SonderPreis, inserted.LeasPreisAbwAbWo, inserted.BasisRestwert, PePo.ID
INTO @PeBack (KdArtiID, WaschPreis, LeasPreis, VkPreis, SonderPreis, LeasPreisAbwAbWo, BasisRestwert, PePoID)
FROM KdArti
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Vertrag ON KdBer.VertragID = Vertrag.ID
JOIN PePo ON PePo.VertragID = Vertrag.ID
JOIN LastPrArchiv ON LastPrArchiv.KdArtiID = KdArti.ID
JOIN PrArchiv ON LastPrArchiv.PrArchivID = PrArchiv.ID
WHERE PePo.PeKoID = @PeKoID
  AND (KdArti.WaschPreis != PrArchiv.WaschPreis OR KdArti.LeasPreis != PrArchiv.LeasPreis OR KdArti.VkPreis != PrArchiv.VKPreis OR KdArti.SonderPreis != PrArchiv.SonderPreis OR KdArti.BasisRestwert != PrArchiv.BasisRestwert);

INSERT INTO PrArchiv (KdArtiID, PeKoID, Datum, VkPreis, WaschPreis, SonderPreis, LeasPreis, LeasPreisAbwAbWo, BasisRestwert, Ruecknahme, MitarbeiID, Aktivierungszeitpunkt, AnlageUserID_, UserID_)
SELECT PeBack.KdArtiID, -1 AS PeKoID, CAST(N'2022-03-15' AS date) AS Datum, VkPreis, WaschPreis, SonderPreis, LeasPreis, LeasPreisAbwAbWo, BasisRestwert, 1 AS Ruecknahme, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM @PeBack PeBack;

UPDATE PePo SET [Status] = N'R'
WHERE PePo.ID IN (
  SELECT DISTINCT PePoID
  FROM @PeBack
);

INSERT INTO History (TableName, TableID, HistKatID, HistKanID, Zeitpunkt, MitarbeiID, VorgangsNr, Memo, [Status],  ErfasstDurchMitarbeiID, ErledigtDurchMitarbeiID, VertragID, EMailMsgID, Betreff, HistRichID, HistVorgID, ErfasstAm, ErledigtAm, AnlageUserID_, UserID_)
SELECT N'KUNDEN' AS TableName, PeHistory.KundenID, 10125 AS HistKatID, 4 AS HistKanID, GETDATE() AS Zeitpunkt, @UserID AS MitarbeiID, NEXT VALUE FOR NEXTID_HISTORYVORGANG AS VorgangsNr, N'Preiserhöhung für Vertrag zurückgenommen, Preiserhöhung: PE FRESH APRIL 2022 9,4%, Vertrag: ' + Vertrag.VertragNr AS Memo, N'S' AS [Status], @UserID AS ErfasstDurchMitarbeiID, @UserID AS ErledigtDurchMitarbeiID, Vertrag.ID AS VertragID, NULL AS EMailMsgID, N'Rücknahme Preiserhöhung' AS Betreff, 3 AS HistRichID, 1 AS HistVorgID, GETDATE() AS ErfasstAm, GETDATE() AS ErledigtAm, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM (
  SELECT DISTINCT KdArti.KundenID, KdBer.VertragID
  FROM @PeBack PeBack
  JOIN KdArti ON PeBack.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
) AS PeHistory
JOIN Vertrag ON PeHistory.VertragID = Vertrag.ID;

DELETE FROM VsaTexte
WHERE Memo = N'Sehr geehrte Damen und Herren 
wie alle Branchen sind auch wir von Preissteigerungen in vielen Bereichen betroffen. 
Besonders wirken sich aktuell Personalkosten sowie die hohen Rohstoffpreise aus, die sich vor allem beim Produkteinkauf auswirken
Fast ein Drittel davon können wir durch kostensenkende Maßnahmen intern abfangen, einen Teil müssen wir jedoch als Preissteigerung an unsere Kunden weitergeben. 
Daher entsteht eine Anpassung bei Blue Care von Fresh 9,40% auf unsere alten Preise. 
Wir schätzen unsere Zusammenarbeit sehr und danken für Ihr Verständnis.'
  AND AnlageUserID_ = 9012688
  AND CAST(Anlage_ AS date) = N'2022-03-10';