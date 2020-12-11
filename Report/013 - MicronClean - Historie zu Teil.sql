DECLARE @Barcode nvarchar(33) = $1$;

DECLARE @OPDaten TABLE (
  OPTeileID int,
  OPEtiKoID int,
  EtiNr nchar(20) COLLATE Latin1_General_CS_AS,
  DruckZeitpunkt datetime2,
  ChargeNr int,
  Zeitpunkt datetime2
);

DECLARE @Teileinfos TABLE (
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS,
  KdNr int,
  Kunde nchar(20) COLLATE Latin1_General_CS_AS,
  VsaNr int,
  VsaBez nvarchar(60) COLLATE Latin1_General_CS_AS,
  TraegerNr nchar(10) COLLATE Latin1_General_CS_AS,
  Vorname nvarchar(25) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(30) COLLATE Latin1_General_CS_AS,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  Artikelbezeichnung nvarchar(60) COLLATE Latin1_General_CS_AS,
  Groesse nchar(10) COLLATE Latin1_General_CS_AS,
  ScanZeitpunkt datetime2,
  ScanOrt nvarchar(60) COLLATE Latin1_General_CS_AS,
  WaschChargeNr int,
  WaschChargeStart datetime2,
  WaschChargeStop datetime2,
  LsNr int,
  Lieferdatum date,
  NextOPEtiKoID int,
  EtiNr nchar(20) COLLATE Latin1_General_CS_AS,
  SteriChargeNr int,
  SteriZeitpunkt datetime2
);

INSERT INTO @OPDaten (OPTeileID, OPEtiKoID, DruckZeitpunkt, EtiNr, ChargeNr, Zeitpunkt)
SELECT OPTeile.ID AS OPTeileID, OPEtiKo.ID AS OPEtiKoID, OPEtiKo.DruckZeitpunkt, OPEtiKo.EtiNr, OPCharge.ChargeNr, OPCharge.Zeitpunkt
FROM Teile
JOIN OPTeile ON Teile.OPTeileID = OPTeile.ID
JOIN OPEtiPo ON OPEtiPo.OPTeileID = OPTeile.ID
JOIN OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
JOIN OPCharge ON OPEtiKo.OPChargeID = OPCharge.ID
WHERE Teile.Barcode = @Barcode;

INSERT INTO @Teileinfos (Barcode, KdNr, Kunde, VsaNr, VsaBez, TraegerNr, Vorname, Nachname, ArtikelNr, Artikelbezeichnung, Groesse, ScanZeitpunkt, ScanOrt, WaschChargeNr, WaschChargeStart, WaschChargeStop, LsNr, Lieferdatum, NextOPEtiKoID)
SELECT Teile.Barcode, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBez, Traeger.Traeger AS TraegerNr, Traeger.Vorname, Traeger.Nachname, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Scans.[DateTime] AS ScanZeitpunkt, ZielNr.ZielNrBez$LAN$ AS ScanOrt, WaschCh.ID AS WaschChargeNr, WaschCh.ZeitStart AS WaschChargeStart, WaschCh.ZeitEnde AS WaschChargeStart, IIF(LsKo.ID < 0, NULL, LsKo.LsNr) AS LsNr, LsKo.Datum AS Lieferdatum, NextOPEtiKoID = (
  SELECT TOP 1 OPDaten.OPEtiKoID
  FROM @OPDaten AS OPDaten
  WHERE CAST(OPDaten.DruckZeitpunkt AS date) >= CAST(Scans.[DateTime] AS date)
  ORDER BY OPDaten.DruckZeitpunkt ASC
)
FROM Scans
JOIN Teile ON Scans.TeileID = Teile.ID
JOIN TraeArti ON Teile.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
JOIN WaschCh ON Scans.WaschChID = WaschCh.ID
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
WHERE Teile.Barcode = @Barcode;

UPDATE Teileinfos SET EtiNr = OPEtiKo.EtiNr, SteriChargeNr = OPCharge.ChargeNr, SteriZeitpunkt = OPCharge.Zeitpunkt
FROM @Teileinfos AS Teileinfos
JOIN OPEtiKo ON TeileInfos.NextOPEtiKoID = OPEtiKo.ID
JOIN OPCharge ON OPEtiKo.OPChargeID = OPCharge.ID
WHERE LsNr IS NOT NULL;

SELECT Barcode, KdNr, Kunde, VsaNr, VsaBez AS [Vsa-Bezeichnung], TraegerNr AS Trägernummer, Vorname, Nachname, ArtikelNr, Artikelbezeichnung, Groesse AS Größe, ScanZeitpunkt AS [Scan-Zeitpunkt], ScanOrt AS [Scan-Ort], WaschChargeNr AS [Waschcharge-Nummer], WaschChargeStart AS [Startzeit Waschcharge], WaschChargeStop AS [Endzeit Waschcharge], LsNr, Lieferdatum, EtiNr AS [Seriennummer Set], SteriChargeNr AS [Sterilcharge Nummer], SteriZeitpunkt AS [Sterilcharge Zeitpunkt]
FROM @Teileinfos
ORDER BY ScanZeitpunkt DESC;