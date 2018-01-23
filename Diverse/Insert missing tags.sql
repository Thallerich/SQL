UPDATE __tagsen SET EANSerial = LEFT(EANSerial, POSITION('.' IN EANSerial) -1 );

SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, Artikel.EAN, Artikel.BereichID, taglist.Code, taglist.Disposition
INTO __tagsenprepared
FROM __tagsen AS taglist, Artikel
WHERE taglist.EANSerial = Artikel.EAN;

TRY
  DROP TABLE #missingtag;
CATCH ALL END;

SELECT tagsprepared.*
INTO #missingtag
FROM __tagsenprepared AS tagsprepared
LEFT OUTER JOIN OPTeile ON tagsprepared.Code = OPTeile.Code
WHERE OPTeile.Code IS NULL;

SELECT DISTINCT BereichID, BereichBez FROM #missingtag mt, Bereich WHERE mt.BereichID = Bereich.ID;
  
INSERT INTO OPTeile (ID, Status, Code, ArtikelID, Erstwoche, Freigabe, ZielNrID)
SELECT GetNextID('OPTEILE') AS ID, 'A' AS Status, missingtag.Code, missingtag.ArtikelID, '1980/01' AS Erstwoche, $TRUE$ AS Freigabe, 10000060 AS ZielNrID
FROM #missingtag AS missingtag
WHERE NOT EXISTS (SELECT * FROM OPTeile WHERE OPTeile.Code2 = missingtag.Code)
  AND NOT EXISTS (SELECT * FROM Teile WHERE Teile.Barcode = missingtag.Code);