SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Teile.Barcode, Status.Bez AS Status, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, IIF(Teile.Ausdienst IS NULL, Teile.RestwertInfo, Teile.AusdRestW) AS Restwert, Teile.EKPreis
FROM Teile, Traeger, Vsa, Kunden, Holding, Artikel, (SELECT Status.Status, Status.StatusBez$LAN$ AS Bez FROM Status WHERE Status.Tabelle = 'TEILE') AS Status
WHERE Teile.TraegerID = Traeger.ID
  AND Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Kunden.HoldingID = Holding.ID
  AND Teile.Status = Status.Status
  AND Holding.Holding = 'KHBG'
  AND Kunden.KdNr <> 30997
  AND Teile.Status IN ('Q', 'W')
  AND IIF(Teile.Status = 'Q', CURDATE() - Teile.Ausgang1 > 180 AND Teile.Ausgang1 > Teile.Eingang1, 1 = 1);
  
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunden, Vsa.SuchCode AS VsaStichwort, Vsa.Bez AS Vsa, OPEtiKo.EtiNr, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, CONVERT(OPCharge.Zeitpunkt, SQL_DATE) AS Sterilisationsdatum, CONVERT(OPEtiKo.AusleseZeitpunkt, SQL_DATE) AS Auslesedatum, OPEtiKo.VerfallDatum
FROM OPEtiKo, Vsa, Kunden, Holding, Artikel, ArtGru, OPCharge
WHERE OPEtiKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND OPEtiKo.ArtikelID = Artikel.ID
  AND OPEtiKo.OPChargeID = OPCharge.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND ArtGru.Steril = $TRUE$
  AND Holding.Holding = 'KHBG'
  AND OPEtiKo.Status = 'R'
  AND OPEtiKo.VerfallDatum <= CURDATE();
  
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.Suchcode AS VsaStichwort, Vsa.Bez AS Vsa, OPTeile.Code, OPTeileArti.ArtikelNr, OPTeileArti.ArtikelBez$LAN$, OPTeile.RestwertInfo AS Restwert, CONVERT(OPTeile.LastScanTime, SQL_DATE) AS LetzterScan, OPEtiKo.EtiNr, Artikel.ArtikelNr AS SetArtikelNr, Artikel.ArtikelBez$LAN$ AS SetArtikelBez, CONVERT(OPEtiKo.AusleseZeitpunkt, SQL_DATE) AS AusleseDatum
FROM OPEtiPo, OPEtiKo, Vsa, Kunden, Holding, Artikel, ArtGru, OPTeile, Artikel AS OPTeileArti
WHERE OPEtiPo.OPEtiKoID = OPEtiKo.ID
  AND OPEtiKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.HoldingID = Holding.ID
  AND OPEtiKo.ArtikelID = Artikel.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND OPEtiPo.OPTeileID = OPTeile.ID
  AND OPTeile.LastOPEtiKoID = OPEtiPo.OPEtiKoID
  AND OPTeile.ArtikelID = OPTeileArti.ID
  AND OPTeile.Status = 'R'
  AND ArtGru.Steril = $TRUE$
  AND Holding.Holding = 'KHBG'
  AND OPEtiKo.Status = 'U';
  
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(OPTeile.ID) AS Menge, SUM(OPTeile.AusdRestwert) AS Gutschrift
FROM OPTeile, Vsa, Kunden, Holding, RechPo, RechKo, Artikel 
WHERE RechPo.RPoTypeID = 23 
  AND Vsa.Status = 'A' 
  AND Vsa.ID = OPTeile.VsaID 
  AND Vsa.KundenID = Kunden.ID 
  AND OPTeile.Status < 'W' 
  AND OPTeile.RechPoID = RechPo.ID 
  AND Kunden.HoldingID = Holding.ID
  AND Holding.Holding = 'KHBG'    
  AND RechPo.RechKoID = RechKo.ID
  AND CURDATE() - RechKo.RechDat <= 120
  AND OPTeile.ArtikelID = Artikel.ID
GROUP BY Kunden.KdNr, Kunde, Artikel.ArtikelNr, Artikelbezeichnung;