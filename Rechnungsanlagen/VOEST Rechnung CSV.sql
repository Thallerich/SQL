/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ TODO: BUKRS befüllen -> user defined field in Tabelle KUNDEN                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT N'' AS BELNR_D, -1 AS BUKRS, RechKo.RechDat AS BLDAT, N'' AS BUDAT, 99 AS BLART, RechKo.RechDat AS XBLNR, Wae.IsoCode AS WAERS, 40 AS BSCHL, 721000 AS HKONT, RechPo.GPreis AS WRBTR, N'V0' AS MWSKZ, Abteil.Bez AS KOSTL, N'' AS AUFNR, RechPo.Menge AS MENGE_D, ME.IsoCode AS MEINS, IIF(Artikel.ArtikelBez IS NOT NULL, Artikel.ArtikelBez, RechPo.Bez) AS SGTEXT
FROM RechKo, RechPo, Abteil, VSA, Artikel, KdArti, Wae, ME
--WHERE RechKo.ID = $RECHKOID$
WHERE RechKo.RechNr = 30006396 
AND RechPo.RechKoID = RechKo.ID
AND Abteil.ID = RechPo.AbteilID
AND VSA.ID = RechPo.VsaID
AND Artikel.ID = KdArti.ArtikelID
AND KdArti.ID = RechPo.KdArtiID
AND RechKo.WaeID = Wae.ID
AND Artikel.MeID = ME.ID;