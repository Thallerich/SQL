TRY
  DROP TABLE #TmpTeileHinw;
CATCH ALL END;

SELECT Teile.ID
INTO #TmpTeileHinw
FROM Teile, Vsa, Kunden, ViewArtikel Artikel, ArtGroe, Status, Traeger
WHERE Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND Teile.ArtGroeID = ArtGroe.ID
  AND Teile.Status = Status.Status
  AND Status.Tabelle = 'TEILE'
  AND Teile.TraegerID = Traeger.ID
  AND Kunden.FirmaID = 5001             -- Firma Umlauft
  AND Teile.PatchDatum = '30.08.2013'   -- Patchdatum der Teile
  AND Teile.AltenheimModus = 0;         -- Nur BK
  
INSERT INTO Hinweis
SELECT GetNextID('HINWEIS') AS ID, TH.ID AS TeileID, TRUE AS Aktiv, 'A' AS StatusSDC, 'Druckfehler bei Patch -  Schrank Kontrolle' AS Hinweis, '2099/52' AS BisWoche, 1 AS Anzahl, -1 AS HinwTNextID, CURDATE() AS EingabeDatum, 'STHA' AS EingabeUser, CONVERT(NULL, SQL_TIMESTAMP) AS BestaetDatum, '' AS BestaetUser, FALSE AS AufLS, FALSE AS Patchen, TRUE AS Wichtig, FALSE AS AbTeilAktiv, -1 AS SdcDevID, -1 AS SdcHinwID, -1 AS MinSdcProdID, NOW() AS Anlage_, NOW() AS Update_, 'STHA' AS User_, 'STHA' AS AnlageUser_
FROM #TmpTeileHinw TH;

UPDATE Teile SET HasHinweis = TRUE
WHERE ID IN (SELECT ID FROM #TmpTeileHinw);