SELECT N'' AS BELNR_D, Kunden._KdBuKr AS BUKRS, RechKo.RechDat AS BLDAT, N'' AS BUDAT, 99 AS BLART, RechKo.RechNr AS XBLNR, Wae.IsoCode AS WAERS, 40 AS BSCHL, 721000 AS HKONT, RechPo.GPreis AS WRBTR, N'V0' AS MWSKZ, Abteil.Bez AS KOSTL, N'' AS AUFNR, RechPo.Menge AS MENGE_D, ME.IsoCode AS MEINS, IIF(Artikel.ArtikelBez IS NOT NULL, Artikel.ArtikelBez, RechPo.Bez) AS SGTEXT
FROM RechKo, RechPo, Abteil, VSA, Artikel, KdArti, Wae, ME, Kunden
WHERE RechKo.ID = $RECHKOID$
AND RechPo.RechKoID = RechKo.ID
AND Abteil.ID = RechPo.AbteilID
AND VSA.ID = RechPo.VsaID
AND Artikel.ID = KdArti.ArtikelID
AND KdArti.ID = RechPo.KdArtiID
AND RechKo.RechWaeID = Wae.ID
AND Artikel.MeID = ME.ID
AND RechKo.KundenID = Kunden.ID;