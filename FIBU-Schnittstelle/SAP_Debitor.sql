/*******************************************************************************************************************************
**                                                                                                                            **
** Debitoren-Export zu ITM - erstellt von Stefan Thaller, Wozabal Miettex GmbH, 06.11.2018, Version 1.4                       **
** laut Schnittstellenbeschreibung: Debitorenüberleitung.docx                                                                 **
**                                                                                                                            **
*******************************************************************************************************************************/


SELECT DE.Debitor AS CustomerNumber, 
  Standort.SuchCode AS BusinessUnit,
  DE.Debitor AS AccountNumber,
  DE.SuchCode AS [Name],
  DE.Name1 AS LegalName,
  LEFT(DE.SuchCode, 20) AS SearchName,
  NULL AS LegacyCustomerNumber,
  IIF(LEN(DE.AnsprechTelefon) > 15, NULL, DE.AnsprechTelefon) AS PhoneNo,
  IIF(LEN(DE.AnsprechTelefax) > 15, NULL, DE.AnsprechTelefax) AS FaxNo,
  REPLACE(AnsprecheMail, N';', N',') AS EMail,
  FORMAT(DE.KundeSeit, N'dd/MM/yyyy') AS DateActive,
  NULL AS DateInactive,
  N'Y' AS Active,
  NULL AS Remark,
  N'DIV' AS SicCode,                                                                                -- Branchencode - aktuell im AdvanTex nicht gepflegt - daher standardmäßig DIV - STHA, 15.03.2018
  1 AS MasterAccount,
  NULL AS MasterAccountNumber,
  KdGf.KurzBez AS MarketSegmentCode,
  KdGf.KurzBez AS MarketSegmentDesc,
  SalesAreaCode = 
    CASE
      WHEN DE.Firma = N'UKLU' THEN N'SÜD'
      WHEN DE.Firma = N'SMBU' AND DE.Land = N'CZ' THEN N'CZ'
      WHEN DE.Firma = N'SAL' AND Standort.SuchCode = N'UKLU' THEN N'SÜD'
      WHEN DE.Firma = N'SAL' AND Standort.SuchCode <> N'UKLU' THEN N'WEST'
      ELSE N'WEST'
    END,
  SalesAreaDesc = 
    CASE
      WHEN DE.Firma = N'UKLU' THEN N'SÜD'
      WHEN DE.Firma = N'SMBU' AND DE.Land = N'CZ' THEN N'CZ'
      WHEN DE.Firma = N'SAL' AND Standort.SuchCode = N'UKLU' THEN N'SÜD'
      WHEN DE.Firma = N'SAL' AND Standort.SuchCode <> N'UKLU' THEN N'WEST'
      ELSE N'WEST'
    END,
  DE.Strasse AS MailAddress,
  NULL AS MailAddress2,
  DE.PLZ AS MailZipcode,
  DE.Ort AS MailCity,
  MailCounty =                                                                                      -- Für DE / AT: Bundesland über Sektor ermitteln; alle anderen Länder: Länderkennzeichen übergeben
    CASE DE.Land
      WHEN N'IT' THEN N'I'
      WHEN N'BE' THEN N''
      ELSE ISNULL(Sektor.Sektor, DE.Land)
    END,
  NULL AS MailState,
  DE.Land AS Country,
  DE.Waehrung AS Currency,
  DE.Strasse AS DeliveryAddress,
  NULL AS DeliveryAddress2,
  DE.PLZ AS DeliveryZipcode,
  DE.Ort AS DeliveryCity,
  NULL AS DeliveryCounty,
  NULL AS DeliveryState,
  N'MAIL' AS CommunicationMethodCode,
  N'Email' AS CommunicationMehtodDesc,
  N'Y' AS SoilCount,
  1 AS ReturnLinen,
  1 AS ReturnGarments,
  NULL AS StartDateHoliday,
  NULL AS EndDateHoliday,
  0 AS DaysNoPrepCharge,
  0 AS DaysSpecialGrade,
  NULL AS FirstDaysGradeCode,
  NULL AS FirstIssueGradeCode,
  NULL AS QualityGradeCode,
  0 AS ChargeRepairs,
  1 AS GarmentRentSpecification,
  N'N' AS SwingSuitDelivery,
  LEFT(DE.SuchCode, 20) AS CustomerMarkInLabel,
  NULL AS UsesGarmentDispenser,
  NULL AS UseDispenserObligated,
  N'N' AS CorrectShortages,
  N'N' AS CorrectOverdeliveries,
  N'N' AS Lockermanagement,
  N'Y' AS CodeGarmentUniquely,
  1 AS StandardQtyDefinition,
  5 AS PaymentType,
  2 AS PaymentMethod,
  NULL AS MinimumInvoiceAmount,
  NULL AS InvoiceLayoutCode,
  1 AS InvoiceCopies,
  NULL AS OldSpecificAdjPercentage,
  NULL AS MinAdjAmount,
  NULL AS MaxAdjAmount,
  NULL AS NewSpecificAdjPercentage,
  NULL AS StartDateNewPercentage,
  NULL AS RemarkInvoice,
  N'N' AS Taxable,
  NULL AS StateTaxAuthorityCode,
  NULL AS CityTaxAuthorityCode,
  NULL AS CountyTaxAuthorityCode,
  NULL AS ContractCode,
  NULL AS ContractDateActive,
  NULL AS ContractDateInactive,
  NULL AS ContractSignDate,
  NULL AS ContractContinueService,
  NULL AS ContractSignalingWeeks,
  NULL AS NextAnniversaryDate,
  NULL AS GainReasonCode,
  NULL AS GainReasonDesc,
  NULL AS LostReasonCode,
  NULL AS LostReasonDesc,
  NULL AS GainCompetitorCode,
  NULL AS GainCompetitorName,
  NULL AS LostCompetitorCode,
  NULL AS LostCompetitorName,
  NULL AS PurchaseOrder,
  NULL AS PurchaseOrderExpDate,
  0 AS PurchaseOrderValue,
  0 AS EstimatedWeeklySales,
  1 AS AnniversaryPriceAdj,
  N'N' AS CPIBased,
  0 AS FixedWeightPerc,
  0 AS FixedSalesPerc,
  0 AS FixedReplacePerc,
  0 AS FixedRentPerc,
  0 AS FixedWashPerc,
  0 AS PrepCharge,
  IIF(Holding.ID = -1, N'DIV', LEFT(Holding.Holding, 10)) AS ChainCode,
  IIF(Holding.ID = -1, N'DIV', Holding.Bez) AS ChainName,
  NULL AS InvoicingClusterCoder,
  0 AS RentPeriod,
  DE.UstIdNr AS VATNumber,
  0 AS GarmentInsurance,
  0 AS GarmentInsurancePrice,
  NULL AS LastSurveyDate,
  NULL AS SurveyFrequency,
  N'N' AS UsesBundles,
  NULL AS ILNNumber,
  DE.Name2 AS ExtraName1,
  DE.Name3 AS ExtraName2,
  0 AS RestockingPrice,
  NULL AS RestockingStartDate,
  1 AS SalesEmployeeNumber,
  N'KEIN VERTRETER' AS SalesEmployeeName,
  N'N' AS SignatureRequired,
  N'N' AS ChargeWashFirstIssue,
  0 AS NationalAccountCode,
  0 AS NationalAccountName,
  200 AS InvoiceFrequency,
  NULL AS COCNumber,
  0 AS PNumber,
  NULL AS ServiceEmployeeNumber,
  NULL AS ServiceEmployeeName,
  1 AS RankingPriority,
  1 AS Ranking,
  N'Y' AS ChargeResidualValue,
  NULL AS ChargeLossCharge,
  NULL AS CutOffDate,
  0 AS EDIMethod,
  NULL AS EDIContactPersonNumber,
  NULL AS RequisitionNumber,
  NULL AS AccountingString,
  NULL AS TaxExemptCode,
  0 AS SplitInvoices,
  NULL AS RouteDescription,
  N'N' AS InheritMAPricelist,
  N'N' AS RestrictOnMapProducts,
  NULL AS SalesEmployeeNumber1,
  NULL AS SalesEmployeeName1,
  NULL AS SalesEmployeeNumber2,
  NULL AS SalesEmployeeName2,
  N'N' AS SplitInvoicesPerActivity,
  0 AS ChargeRepairCog,
  NULL AS CodeLabelLayoutCode,
  NULL AS CodeLabelLayouDesc,
  NULL AS NameLabelLayouCode,
  NULL AS NameLabelLayouDesc,
  DE.Zahlziel AS Zahlungsbedingung,
  NULL AS Zahlweg,
  NULL AS UIDNummer
FROM #DebitorExport DE
LEFT OUTER JOIN KdGf ON DE.GfBez = KdGf.Bez
LEFT OUTER JOIN Kunden ON DE.KundenID = Kunden.ID
LEFT OUTER JOIN Firma ON Kunden.FirmaID = Firma.ID
LEFT OUTER JOIN Standort ON Kunden.StandortID = Standort.ID
LEFT OUTER JOIN Holding ON Kunden.HoldingID = Holding.ID
LEFT OUTER JOIN SektPLZ ON Kunden.Land = SektPLZ.Land AND Kunden.PLZ = SektPLZ.PLZ
LEFT OUTER JOIN Sektor ON SektPLZ.SektorID = Sektor.ID
WHERE (
    (Firma.SuchCode <> N'SAL' AND LEN(DE.Debitor) = 7 AND LEFT(DE.Debitor, 2) IN (N'23', N'24', N'25', N'27', N'28'))
    OR (Firma.SuchCode <> N'SAL' AND LEN(DE.Debitor) = 9 AND LEFT(DE.Debitor, 2) IN (N'27', N'28'))
    OR Firma.SuchCode = N'SAL'
  )
  AND KdGf.Status = N'A'
  AND KdGf.FibuNr <> 0
  AND Kunden.StandortID > 0;