-- Auswertung Schwund OP-Teile (aktueller Teile-Status = beim Kunde!)
DECLARE @von TIMESTAMP;
DECLARE @bis TIMESTAMP;

@von = CONVERT('01.01.2010 00:00:00', SQL_TIMESTAMP);
@bis = CONVERT('31.01.2014 23:59:59', SQL_TIMESTAMP);

SELECT KdGf.KurzBez AS SGF, Bereich.Bez AS Bereich,  CONVERT(Kunden.KdNr, SQL_VARCHAR) + ' ' + Kunden.SuchCode AS Kunde, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.ArtikelNr2 AS BMDNr, COUNT(OPTeile.ID) AS [Anzahl Teile]
FROM OPTeile, Vsa, Kunden, ViewArtikel Artikel, KdGf, ViewBereich Bereich
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND Artikel.BereichID = Bereich.ID
  AND Bereich.LanguageID = $LANGUAGE$
  AND Kunden.KdGfID = KdGf.ID
  AND Kunden.ID IN (
    SELECT Kunden.ID
    FROM Kunden
    WHERE Kunden.SuchCode LIKE 'DKH %'
  )
  AND OPTeile.Status = 'R' --nur Teile beim Kunden
  AND OPTeile.ID IN (
    SELECT OPScans.OPTeileID
    FROM OPScans
    WHERE OPScans.AnfPoID > 0
      AND OPScans.Zeitpunkt BETWEEN @von AND @bis
  )
  AND (OPTeile.LastScanTime IS NULL OR OPTeile.LastScanTime < @bis)
GROUP BY SGF, Bereich, Kunde, Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, BMDNr;

-- Restore OP-Scans
INSERT INTO OPScans
SELECT ID, Zeitpunkt, OPTeileID, ZielNrID, OPGrundID, AnfPoID, ArbPlatzID, VPSPoID, EingAnfPoID, Menge, OPEtiKoID, VonLagerBewID, NachLagerBewID, Anlage_, Update_, User_, AnlageUser_
FROM _OPScansOld
WHERE NOT EXISTS (SELECT ID FROM OPScans WHERE _OPScansOld.ID = OPScans.ID);

-- Zusammenfassen ausgelagerter OP-Scans
SELECT ID, Zeitpunkt, OpTeileID, ZielNrID, OpGrundID, AnfPoID, -1 AS ArbPlatzID, -1 AS VPSPoID, -1 AS EingAnfPoID, Menge, -1 AS OpEtiKoID, -1 AS VonLagerBewID, -1 AS NachLagerBewID, Anlage_, Update_, User_, AnlageUser_
INTO _OPScansOld
FROM _OPScans_1;

INSERT INTO _OPScansOld
SELECT ID, Zeitpunkt, OpTeileID, ZielNrID, OpGrundID, AnfPoID, -1 AS ArbPlatzID, -1 AS VPSPoID, -1 AS EingAnfPoID, Menge, -1 AS OpEtiKoID, -1 AS VonLagerBewID, -1 AS NachLagerBewID, Anlage_, Update_, User_, AnlageUser_
FROM _OPScans_2
WHERE NOT EXISTS (SELECT ID FROM _OPScansOld WHERE _OPScansOld.ID = _OPScans_2.ID);