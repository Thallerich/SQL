USE AWSInvest;
GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO EKPO (Einkaufsbeleg, Position, Löschkennzeichen, LetzteÄnderung, Kurztext, Material, Material2, Buchungskreis, Werk, Lagerort, Warengruppe, Einkaufsinfosatz, Lieferantenmaterialnr, Zielmenge, Bestellmenge, Bestellmengeneinheit, BestellpreisME, Mengenumrechnung, Mengenumrechnung2, entspricht, Nenner, Bestellnettopreis, Preiseinheit, Bestellnettowert, Bruttobestellwert, Steuerkennzeichen, InfoUpdate, Anzahl_Mahnungen, Mahnung1, Mahnung2, Mahnung3, Tol_Überlieferung, Unbegrenzte_Überl, Tol_Unterlieferung, Bewertungsart, Bewertungstyp, Absagekennzeichen, Endlieferung, Endrechnung, Positionstyp, Kontierungstyp, Verbrauch, Verteilungskennz, Teilrechnung, Wareneingang, WEunbewertet, Rechnungseingang, Webez_RechnPrüfung, Bestätigungspflicht, Auftragsbestätigung, Rahmenvertrag, Pos_d_überg_Vertrags, Basismengeneinheit, Zielwert_Rahmenvertr, Nicht_abzugsfähig, Normalabrufmenge, Preisdatum, Einkaufsbelegtyp, Effektivwert, Obligorelevant, Kunde, Adresse, FortschreibGruppe, Planlieferzeit, Nettogewicht, Gewichtseinheit, EAN_UPC_Code, BestätigSteuerung, Bruttogewicht, Volumen, Volumeneinheit, Incoterms, Incoterms2, Bestellnettowert2, Statistisch, Lieferant, LBLieferant, Werksüberg_konf_Mat, Materialtyp, Adresse2, InterneObjektnummer, Bestellanforderung, BanfPosition, Materialart, Zwischensumme1, Zwischensumme2, Zwischensumme3, Naturalrabattfähig, Bonusbasis, Anforderer, Dispobereich, Bedarfsdringlichkeit, Bedarfspriorität, Anlegedatum, Anlegeuhrzeit, EinbehaltProzent, Anzahlung, Anzahlungsprozentsatz, Anzahlungsbetrag, Fälligkeitsdatum_Anzahlung, Reservierung, PosNr_UmlagReservierung, Pool_einzelcodiert_gestattet, Bestellposition_ID_Advantex)
    SELECT
      CAST(Einkaufsbeleg AS bigint),
      CAST(Position AS int),
      CAST(Löschkennzeichen AS char(1)),
      CONVERT(date, LetzteÄnderung, 104),
      CAST(Kurztext AS nvarchar(40)),
      CAST(Material AS nchar(20)),
      CAST(Material2 AS nchar(20)),
      CAST(Buchungskreis AS smallint),
      CAST(Werk AS char(4)),
      CAST(Lagerort AS char(4)),
      CAST(Warengruppe AS char(4)),
      CAST(Einkaufsinfosatz AS bigint),
      CAST(Lieferantenmaterialnr AS nvarchar(40)),
      CAST(CAST(REPLACE(REPLACE(Zielmenge, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(CAST(REPLACE(REPLACE(Bestellmenge, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(Bestellmengeneinheit AS char(3)),
      CAST(BestellpreisME AS char(3)),
      CAST(CAST(REPLACE(REPLACE(Mengenumrechnung, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(CAST(REPLACE(REPLACE(Mengenumrechnung2, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(CAST(REPLACE(REPLACE(entspricht, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(CAST(REPLACE(REPLACE(Nenner, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(REPLACE(REPLACE(Bestellnettopreis, N',', N'.'), N' ', N'') AS money),
      CAST(CAST(REPLACE(REPLACE(Preiseinheit, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(REPLACE(REPLACE(Bestellnettowert, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Bruttobestellwert, N',', N'.'), N' ', N'') AS money),
      CAST(Steuerkennzeichen AS char(2)),
      CAST(InfoUpdate AS char(1)),
      CAST(CAST(REPLACE(REPLACE(Anzahl_Mahnungen, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(CAST(REPLACE(REPLACE(Mahnung1, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(CAST(REPLACE(REPLACE(Mahnung2, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(CAST(REPLACE(REPLACE(Mahnung3, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(REPLACE(REPLACE(Tol_Überlieferung, N',', N'.'), N' ', N'') AS numeric(4, 1)),
      CASE Unbegrenzte_Überl WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(REPLACE(REPLACE(Tol_Unterlieferung, N',', N'.'), N' ', N'') AS numeric(4, 1)),
      CAST(Bewertungsart AS char(1)),
      CAST(Bewertungstyp AS char(1)),
      CASE Absagekennzeichen WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CASE Endlieferung WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(Endrechnung AS char(1)),
      CAST(Positionstyp AS char(1)),
      CAST(Kontierungstyp AS char(1)),
      CAST(Verbrauch AS char(1)),
      CAST(Verteilungskennz AS char(1)),
      CAST(Teilrechnung AS char(1)),
      CASE Wareneingang WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CASE WEunbewertet WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CASE Rechnungseingang WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CASE Webez_RechnPrüfung WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CASE Bestätigungspflicht WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(Auftragsbestätigung AS nvarchar(40)),
      CAST(Rahmenvertrag AS bigint),
      CAST(Pos_d_überg_Vertrags AS int),
      CAST(Basismengeneinheit AS char(3)),
      CAST(REPLACE(REPLACE(Zielwert_Rahmenvertr, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Nicht_abzugsfähig, N',', N'.'), N' ', N'') AS numeric(4, 1)),
      CAST(REPLACE(REPLACE(Normalabrufmenge, N',', N'.'), N' ', N'') AS numeric(8, 2)),
      CONVERT(date, Preisdatum, 104),
      CAST(Einkaufsbelegtyp AS char(1)),
      CAST(REPLACE(REPLACE(Effektivwert, N',', N'.'), N' ', N'') AS money),
      CASE Obligorelevant WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(Kunde AS char(1)),
      CAST(Adresse AS nvarchar(15)),
      CAST(FortschreibGruppe AS char(3)),
      CAST(Planlieferzeit AS smallint),
      CAST(REPLACE(REPLACE(Nettogewicht, N',', N'.'), N' ', N'') AS numeric(8, 3)),
      CAST(Gewichtseinheit AS char(2)),
      CAST(EAN_UPC_Code AS nvarchar(20)),
      CAST(BestätigSteuerung AS char(4)),
      CAST(REPLACE(REPLACE(Bruttogewicht, N',', N'.'), N' ', N'') AS numeric(12, 3)),
      CAST(REPLACE(REPLACE(Volumen, N',', N'.'), N' ', N'') AS numeric(12, 3)),
      CAST(Volumeneinheit AS char(2)),
      CAST(Incoterms AS char(3)),
      CAST(Incoterms2 AS nvarchar(30)),
      CAST(REPLACE(REPLACE(Bestellnettowert2, N',', N'.'), N' ', N'') AS money),
      CASE Statistisch WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(Lieferant AS int),
      CASE LBLieferant WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(Werksüberg_konf_Mat AS nchar(20)),
      CAST(Materialtyp AS char(2)),
      CAST(Adresse2 AS nvarchar(15)),
      CAST(InterneObjektnummer AS int),
      CAST(Bestellanforderung AS int),
      CAST(BanfPosition AS tinyint),
      CAST(Materialart AS char(4)),
      CAST(REPLACE(REPLACE(Zwischensumme1, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Zwischensumme2, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Zwischensumme3, N',', N'.'), N' ', N'') AS money),
      CASE Naturalrabattfähig WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(REPLACE(REPLACE(Bonusbasis, N',', N'.'), N' ', N'') AS money),
      CAST(Anforderer AS nvarchar(20)),
      CAST(Dispobereich AS char(5)),
      CAST(Bedarfsdringlichkeit AS tinyint),
      CAST(Bedarfspriorität AS tinyint),
      CONVERT(date, Anlegedatum, 104),
      CAST(Anlegeuhrzeit AS time),
      CAST(REPLACE(REPLACE(EinbehaltProzent, N',', N'.'), N' ', N'') AS numeric(5, 1)),
      CASE Anzahlung WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(REPLACE(REPLACE(Anzahlungsprozentsatz, N',', N'.'), N' ', N'') AS numeric(5, 1)),
      CAST(REPLACE(REPLACE(Anzahlungsbetrag, N',', N'.'), N' ', N'') AS money),
      CONVERT(date, Fälligkeitsdatum_Anzahlung, 104),
      CAST(Reservierung AS tinyint),
      CAST(PosNr_UmlagReservierung AS tinyint),
      CASE Pool_einzelcodiert_gestattet WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(Bestellposition_ID_Advantex AS bigint)
    FROM EKPO_Import;

    DROP TABLE EKPO_Import;
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;

GO