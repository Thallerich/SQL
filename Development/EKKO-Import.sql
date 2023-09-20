USE AWSInvest;
GO

TRUNCATE TABLE EKKO;
GO

INSERT INTO EKKO (Einkaufsbeleg, Buchungskreis, Einkaufsbelegtyp, Einkaufsbelegart, [Status], AnlageDatum, AnlageUser, Positionsintervall, LetztePosition, Lieferant, Zahlungsbedingung, Währung, Währungskurs, KursFixiert, Belegdatum, Laufzeitbeginn, Laufzeitende, Bewerbungsfrist, Angebotsfrist, Bindefrist, Angebot, Angebotsdatum, Rahmenvertrag, WENachricht, Incoterms, Incoterms2, BelegkonditionNr, Rechnungssteller, AußenhandelsdatenNr, KonditionenZeitabhängig, Adressnummer)
SELECT CAST(Einkaufsbeleg AS bigint),
  CAST(Buchungskreis AS smallint),
  CAST(Einkaufsbelegtyp AS char(1)),
  CAST(Einkaufsbelegart AS char(4)),
  CAST([Status] AS char(1)),
  CONVERT(date, AnlageDatum, 104),
  CAST(AnlageUser AS nchar(20)),
  CAST(Positionsintervall AS tinyint),
  CAST(LetztePosition AS int),
  CAST(Lieferant AS int),
  CAST(Zahlungsbedingung AS char(4)),
  CAST(Währung AS char(3)),
  CAST(Währungskurs AS char(8)),
  CAST(KursFixiert AS char(1)),
  CONVERT(date, Belegdatum, 104),
  CONVERT(date, Laufzeitbeginn, 104),
  CONVERT(date, Laufzeitende, 104),
  CONVERT(date, Bewerbungsfrist, 104),
  CONVERT(date, Angebotsfrist, 104),
  CONVERT(date, Bindefrist, 104),
  CAST(Angebot AS char(10)),
  CONVERT(date, Angebotsdatum, 104),
  CAST(Rahmenvertrag AS bigint),
  CASE WENachricht WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
  CAST(Incoterms AS char(3)),
  CAST(Incoterms2 AS nvarchar(30)),
  CAST(BelegkonditionNr AS bigint),
  CAST(Rechnungssteller AS int),
  CAST(AußenhandelsdatenNr AS char(10)),
  CASE KonditionenZeitabhängig WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
  CAST(Adressnummer AS int)
FROM EKKO_Import;

GO