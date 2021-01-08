SELECT ADRGRP.AdrGrpBez$LAN$ AS Adressgruppe, KDGF.KurzBez AS SGF, KUNDEN.KdNr, KUNDEN.SuchCode AS Kunde, KUNDEN.Name1 AS Adresszeile1, KUNDEN.Name2 AS Adresszeile2, KUNDEN.Name3 AS Adresszeile3, KUNDEN.Strasse, KUNDEN.Land, KUNDEN.PLZ, KUNDEN.Ort, STATUS.StatusBez$LAN$ AS Kundenstatus, ISNULL(HasTraeger.HasTraeger, CONVERT(bit, 0)) AS HatTräger
FROM ADRGRP, KDGRU, STATUS, KDGF, KUNDEN
LEFT OUTER JOIN (
  SELECT DISTINCT CONVERT(bit, 1) AS HasTraeger, KUNDEN.ID AS KundenID
  FROM TRAEGER, VSA, KUNDEN
  WHERE TRAEGER.VsaID = VSA.ID
    AND VSA.KundenID = KUNDEN.ID
) AS HasTraeger ON HasTraeger.KundenID = KUNDEN.ID
WHERE KDGRU.AdrGrpID = ADRGRP.ID
  AND KDGRU.KundenID = KUNDEN.ID
  AND KUNDEN.Status = STATUS.Status
  AND STATUS.Tabelle = N'KUNDEN'
  AND KUNDEN.KdGFID = KDGF.ID
  AND ADRGRP.ID IN ($1$)
  AND KUNDEN.SichtbarID IN ($SICHTBARIDS$)
  AND KUNDEN.AdrArtID = 1 --nur tatsächliche Kunden
;