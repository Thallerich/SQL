SELECT RechKo.RechNr, RechKo.RechDat, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(RechPo.Menge) AS Menge, RechPo.EPreis, SUM(RechPo.GPreis) AS GPreis, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, Vsa.SuchCode AS VsaStichwort, Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS KdSuchCode, RechKo.AdressBlock, Kunden.UStIdNr, Wae.IsoCode AS WaeIsoCode, Wae.Format AS EFormat, Wae.FormatFinal AS GFormat, RechKo.Land
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON RechPo.VsaID = Vsa.ID
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Wae ON RechKo.WaeID = Wae.ID
WHERE RechKo.ID = $RECHKOID$
GROUP BY RechKo.RechNr, RechKo.RechDat, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, RechPo.EPreis, Vsa.ID, Vsa.VsaNr, Vsa.Bez, Vsa.SuchCode, Kunden.ID, Kunden.KdNr, Kunden.SuchCode, RechKo.AdressBlock, Kunden.UStIdNr, Wae.IsoCode, Wae.Format, Wae.FormatFinal, RechKo.Land
ORDER BY VsaID, ArtikelNr;

-- Query in report file to output delivery notes
WITH LsData AS (
  SELECT DISTINCT LsKo.VsaID, LsKo.Datum, LsKo.LsNr
  FROM RechPo
  JOIN LsPo ON LsPo.RechPoID = RechPo.ID
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE RechPo.RechKoID = x --Replace x with RechKoID dynamicall in report
)
SELECT FORMAT(LsDataMain.Datum, N'd', N'de-AT') + N': ' + LEFT(LsDataMain.LsNrs, LEN(LsDataMain.LsNrs) - 1) AS Lieferscheine
FROM (
  SELECT DISTINCT LsData2.VsaID, LsData2.Datum, (
    SELECT RTRIM(CAST(LsData.LsNr AS nchar(10))) + N', ' AS [text()]
    FROM LsData
    WHERE LsData.VsaID = LsData2.VsaID AND LsData.Datum = LsData2.Datum
    ORDER BY LsData.VsaID, LsData.Datum
    FOR XML PATH ('')
  ) AS LsNrs
  FROM LsData AS LsData2
  WHERE LsData2.VsaID = x  --Replace x with VsaID dynamically in report
) AS LsDataMain;