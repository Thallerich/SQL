TRY
  DROP TABLE #Artikel;
  DROP TABLE #BestandWE;
  DROP TABLE #BestandWEBC;
  DROP TABLE #TeilEntn;
CATCH ALL END;

SELECT Artikel.ID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez
INTO #Artikel
FROM KdArti, Artikel, Kunden, KdBer, Bereich
WHERE KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND KdArti.KundenID = Kunden.ID
  AND Kunden.KdNr = 2523283
  AND Bereich.Bereich = 'BK'
  AND Artikel.ArtiTypeID = 1;
  
SELECT Bestand.ID, Bestand.ArtGroeID, Bestand.Bestand, Bestand.BestandUrsprung, Bestand.Reserviert, Bestand.Umlauf, Bestand.EPreis, Bestand.GPreis, Bestand.LagerArtID
INTO #BestandWE
FROM Bestand, ArtGroe, #Artikel AS Artikel
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = 6183 --Wareneingang Umlauft
  AND Bestand.Bestand > 0;
  
SELECT Bestand.ID, BestandWe.Bestand, BestandWE.BestandUrsprung, BestandWE.Reserviert, BestandWE.Umlauf, BestandWE.EPreis, BestandWE.GPreis, Bestand.LagerArtID
INTO #BestandWEBC
FROM Bestand, #BestandWE AS BestandWE
WHERE Bestand.ArtGroeID = BestandWE.ArtGroeID
  AND Bestand.LagerArtID = 14486 --Wareneingang Umlauft BC
;

UPDATE Bestand SET Bestand.Bestand = 0, Bestand.BestandUrsprung = 0, Bestand.Reserviert = 0
FROM #BestandWE AS BestandWE
WHERE Bestand.ID = BestandWE.ID;

UPDATE BestOrt SET BestOrt.Bestand = 0, BestOrt.BestandUrsprung = 0, BestOrt.Reserviert = 0
FROM #BestandWE AS BestandWE
WHERE BestOrt.BestandID = BestandWE.ID;

UPDATE Bestand SET Bestand.Bestand = Bestand.Bestand + BestandWEBC.Bestand, Bestand.BestandUrsprung = Bestand.BestandUrsprung + BestandWEBC.BestandUrsprung, Bestand.Reserviert = Bestand.Reserviert + BestandWEBC.Reserviert, Bestand.Umlauf = Bestand.Umlauf + BestandWEBC.Umlauf, Bestand.EPreis = BestandWEBC.EPreis, Bestand.GPreis = BestandWEBC.GPreis
FROM #BestandWEBC AS BestandWEBC
WHERE Bestand.ID = BestandWEBC.ID; 

UPDATE BestOrt SET BestOrt.Bestand = BestOrt.Bestand + BestandWEBC.Bestand, BestOrt.BestandUrsprung = BestOrt.BestandUrsprung + BestandWEBC.BestandUrsprung, BestOrt.Reserviert = BestOrt.Reserviert + BestandWEBC.Reserviert
FROM #BestandWEBC AS BestandWEBC
WHERE BestOrt.BestandID = BestandWEBC.ID;

SELECT Teile.ID AS TeileID, EntnPo.ID AS EntnPoID, Teile.LagerArtID AS LagerArtTeil, EntnPo.LagerArtID AS LagerArtEntn, EntnPo.LagerOrtID
INTO #TeilEntn
FROM Teile, EntnPo, #BestandWE AS Bestand
WHERE Teile.ArtGroeID = Bestand.ArtGroeID
 AND Teile.LagerArtID = Bestand.LagerArtID
 AND Teile.Entnommen = $FALSE$
 AND EntnPo.ID = Teile.EntnPoID
 AND EntnPo.Menge > EntnPo.Entnahmemenge;
 
UPDATE Teile SET Teile.LagerArtID = 14486 WHERE ID IN (SELECT TeileID FROM #TeilEntn);

UPDATE EntnPo SET EntnPo.LagerArtID = 14486 WHERE ID IN (SELECT EntnPoID FROM #TeilEntn);