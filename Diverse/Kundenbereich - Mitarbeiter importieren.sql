DECLARE @BerMaUpdate TABLE (
  KdBerID int,
  KundenserviceID int,
  VertriebID int,
  BetreuungID int,
  RechnungID int
);

INSERT INTO @BerMaUpdate
SELECT KdBer.ID AS KdBerID, ISNULL(Kundenservice.ID, -1) AS KundenserviceID, ISNULL(Vertrieb.ID, -1) AS VertriebID, ISNULL(Betreuung.ID, -1) AS BetreuungID, ISNULL(Rechnung.ID, -1) AS RechnungID
FROM __KdBerMAImport
JOIN Kunden oN __KdBerMAImport.KdNr = Kunden.KdNr
JOIN Bereich ON __KdBerMAImport.Bereiche = Bereich.Bereich
JOIN KdBer ON KdBer.KundenID = Kunden.ID AND KdBer.BereichID = Bereich.ID
LEFT OUTER JOIN Mitarbei AS Kundenservice ON Kundenservice.Name = __KdBerMAImport.Kundenservice
LEFT OUTER JOIN Mitarbei AS Vertrieb ON Vertrieb.Name = __KdBerMAImport.Vertrieb
LEFT OUTER JOIN Mitarbei AS Betreuung ON Betreuung.Name = __KdBerMAImport.Betreuung
LEFT OUTER JOIN Mitarbei AS Rechnung ON Rechnung.Name = __KdBerMAImport.Rechnung;

UPDATE KdBer SET KdBer.ServiceID = BerMaUpdate.KundenserviceID, KdBer.VertreterID = BerMaUpdate.VertriebID, KdBer.BetreuerID = BerMaUpdate.BetreuungID, KdBer.RechKoServiceID = BerMaUpdate.RechnungID
FROM KdBer
JOIN @BerMaUpdate AS BerMaUpdate ON BerMaUpdate.KdBerID = KdBer.ID
WHERE (KdBer.ServiceID != BerMaUpdate.KundenserviceID OR KdBer.VertreterID != BerMaUpdate.VertriebID OR KdBer.BetreuerID != BerMaUpdate.BetreuungID OR KdBer.RechKoServiceID != BerMaUpdate.RechnungID);

UPDATE VsaBer SET VsaBer.ServiceID = BerMaUpdate.KundenserviceID, VsaBer.VertreterID = BerMaUpdate.VertriebID, VsaBer.BetreuerID = BerMaUpdate.BetreuungID
FROM VsaBer
JOIN @BerMaUpdate AS BerMaUpdate ON BerMaUpdate.KdBerID = VsaBer.KdBerID
WHERE (VsaBer.ServiceID != BerMaUpdate.KundenserviceID OR VsaBer.VertreterID != BerMaUpdate.VertriebID OR VsaBer.BetreuerID != BerMaUpdate.BetreuungID);