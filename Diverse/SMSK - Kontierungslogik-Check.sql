-- DROP TABLE IF EXISTS __SMSKKontologik

IF OBJECT_ID(N'__SMSKKontologik') IS NULL
BEGIN
  DECLARE @ImportFile nvarchar(200) = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\SMSK_Kontologik.xlsx';
  DECLARE @XLSXImportSQL nvarchar(max);

  CREATE TABLE __SMSKKontologik (
    RechNr int,
    Erloeskonto nchar(6) COLLATE Latin1_General_CS_AS,
    Erloeskonto_korrekt nchar(6) COLLATE Latin1_General_CS_AS,
    Kostenstelle nchar(7) COLLATE Latin1_General_CS_AS,
    Kostenstelle_korrekt nchar(7) COLLATE Latin1_General_CS_AS
  );

  SET @XLSXImportSQL = N'SELECT CAST(RechNr AS int), ' +
    N'CAST(Erloeskonto AS nchar), ' +
    N'CAST(Erloeskonto_korrekt AS nchar), ' +
    N'CAST(Kostenstelle AS nchar), ' +
    N'CAST(Kostenstelle_korrekt AS nchar) ' +
    N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Sheet1$]);';

  INSERT INTO __SMSKKontologik
  EXEC sp_executesql @XLSXImportSQL;
END

SELECT Bereich.BereichBez AS Bereich, IIF(RechPo.KdArtiID = -1, N'Sonstiges - -1', ArtGru.ArtGruBez) AS Artikelgruppe, RPoType.RPoTypeBez AS Erlösart, Branche.BrancheBez AS Branche, Firma.Bez AS Firma, KdGf.KdGfBez AS SGF, MwSt.MwStBez AS MwSt, RKoType.RKoTypeBez AS RechKoTyp, RechKo.RechDat, RechKo.RechNr, RechKo.Art AS Rechnungsart, Kunden.KdNr, CAST(IIF(RechKo.FibuExpID > 0 , 1, 0) AS bit) AS FIBU, Konten.Konto AS Erlöskonto, RechPo.KsSt AS Kostenträger, __SMSKKontologik.Erloeskonto_korrekt, RIGHT(__SMSKKontologik.Kostenstelle_korrekt, 4) AS Kostenstelle_korrekt
FROM RechPo, RechKo, Bereich, RPoType, Kunden, Firma, MwSt, RKoType, KdGf, Branche, ArtGru, Konten, __SMSKKontologik
WHERE RechPo.RechKoID = RechKo.ID
  AND RechPo.BereichID = Bereich.ID
  AND RechPo.RPoTypeID = RPoType.ID
  AND RechKo.KundenID = Kunden.ID
  AND RechKo.FirmaID = Firma.ID
  AND Kunden.BrancheID = Branche.ID
  AND RechPo.MwStID = MwSt.ID
  AND RechKo.RKoTypeID = RKoType.ID
  AND Kunden.KdGfID = KdGf.ID
  AND RechPo.ArtGruID = ArtGru.ID
  AND RechPo.KontenID = Konten.ID
  AND RechKo.RechNr = __SMSKKontologik.RechNr
  AND Konten.Konto = __SMSKKontologik.Erloeskonto
  AND RechPo.KsSt = RIGHT(__SMSKKontologik.Kostenstelle, 4)
GROUP BY Bereich.BereichBez, IIF(RechPo.KdArtiID = -1, N'Sonstiges - -1', ArtGru.ArtGruBez), RPoType.RPoTypeBez, Branche.BrancheBez, Firma.Bez, KdGf.KdGfBez, MwSt.MwStBez, RKoType.RKoTypeBez, RechKo.RechDat, RechKo.RechNr, RechKo.Art, Kunden.KdNr, CAST(IIF(RechKo.FibuExpID > 0 , 1, 0) AS bit), Konten.Konto, RechPo.KsSt, __SMSKKontologik.Erloeskonto_korrekt, RIGHT(__SMSKKontologik.Kostenstelle_korrekt, 4)
ORDER BY Firma, Bereich, Erlösart;