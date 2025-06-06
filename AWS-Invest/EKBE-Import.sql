USE AWSInvest;
GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO EKBE (Einkaufsbeleg, Position, [Laufende Kontierung], Vorgangsart, Materialbelegjahr, Materialbeleg, Materialbeleg_Position, Bestellentwicklungstyp, Bewegungsart, Buchungsdatum, Menge, Menge_BPR, Betrag_Hauswährung, Betrag, Währung, Ausgleichswert_HW, WESperrbestand_BME, WESperrbestand_BPME, SollHabenKZ, Bewertungsart, Endlieferung, Referenz, Geschäftsjahr_RefBeleg, Referenzbeleg, RefBeleg_Position, Grund_Bewegung, Erfassungsdatum, Erfassungsuhrzeit, Rechnungswert, Einhaltung_Versandvorschrift, Rechnungswert_FW, Material, Werk, WESt_trotz_RE, LfdNr, BelegkondNr, Steuerkennzeichen, Lieferscheinmenge, LieferscheinMngEinh, Material_2, Ausgleichswert_FW, Hauswährung, Menge_2, Charge, Belegdatum, Wertbildung_offen, Kontierung_Rechprüf_ungeplant, AnlageUser, Leistung, Paketnummer, Leistungszeile, LfdBestellkontierung, SrvRetourekennzeichen, Ausgleichswert_FW_2, RechnBetrag_FW, SAPRelease, Menge_3, MengeBPR, Betrag_Hauswährung_2, Betrag_2, Bewerteter_WESperrbst_BME, Bewerteter_WESperrbest_BPME, Abnahme_Lieferant, Ausgleichswert_HW_2, Kursdifferenzbetrag, Einbehalt_Belegwährung, Einbehalt_Buchungskreiswährung, Gebuchter_Einbehalt_Belegwährung, Gebuchter_Einbehalt_BW, Mehrfachkontierung, Währungskurs, Herkunft_Rechnungsposition, Lieferung, Position_2, Bestandssegment, Logisches_System, VAkEtmg, Knz_DIE_abgeschl, Saisonjahr, Saison, Kollektion, Thema, Merkmalsbezeichnung1, Merkmalsbezeichnung2, Merkmalsbezeichnung3)
    SELECT CAST(Einkaufsbeleg AS bigint) AS Einkaufsbeleg,
      CAST(Position AS int) AS Position,
      [Laufende Kontierung] = CASE [Laufende Kontierung] WHEN N'1' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(Vorgangsart AS tinyint) AS Vorgangsart,
      CAST(Materialbelegjahr AS smallint) AS Materialbelegjahr,
      CAST(Materialbeleg AS char(15)),
      CAST(Materialbeleg_Position AS smallint),
      CAST(Bestellentwicklungstyp AS char(1)),
      CAST(Bewegungsart AS char(1)),
      CONVERT(date, Buchungsdatum, 104),
      CAST(CAST(REPLACE(REPLACE(Menge, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(CAST(REPLACE(REPLACE(Menge_BPR, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(REPLACE(REPLACE(Betrag_Hauswährung, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Betrag, N',', N'.'), N' ', N'') AS money),
      CAST(Währung AS char(3)),
      CAST(REPLACE(REPLACE(Ausgleichswert_HW, N',', N'.'), N' ', N'') AS money),
      CAST(CAST(REPLACE(REPLACE(WESperrbestand_BME, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(CAST(REPLACE(REPLACE(WESperrbestand_BPME, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(SollHabenKZ AS char(1)),
      CAST(Bewertungsart AS char(1)),
      CAST(Endlieferung AS char(1)),
      CAST(Referenz AS nchar(20)),
      CAST(Geschäftsjahr_RefBeleg AS smallint),
      CAST(Referenzbeleg AS bigint),
      CAST(RefBeleg_Position AS smallint),
      CAST(Grund_Bewegung AS tinyint),
      CONVERT(date, Erfassungsdatum, 104),
      CAST(Erfassungsuhrzeit AS time),
      CAST(REPLACE(REPLACE(Rechnungswert, N',', N'.'), N' ', N'') AS money),
      CAST(Einhaltung_Versandvorschrift AS char(1)),
      CAST(REPLACE(REPLACE(Rechnungswert_FW, N',', N'.'), N' ', N'') AS money),
      CAST(Material AS nchar(20)),
      CAST(Werk AS char(4)),
      CAST(WESt_trotz_RE AS char(1)),
      CAST(LfdNr AS tinyint),
      CAST(CAST(REPLACE(REPLACE(BelegkondNr, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(Steuerkennzeichen AS char(2)),
      CAST(CAST(REPLACE(REPLACE(Lieferscheinmenge, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(LieferscheinMngEinh AS char(3)),
      CAST(Material_2 AS nchar(20)),
      CAST(REPLACE(REPLACE(Ausgleichswert_FW, N',', N'.'), N' ', N'') AS money),
      CAST(Hauswährung AS char(3)),
      CAST(CAST(REPLACE(REPLACE(Menge_2, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(Charge AS char(1)),
      CONVERT(date, Belegdatum, 104),
      CAST(Wertbildung_offen AS char(1)),
      CAST(Kontierung_Rechprüf_ungeplant AS char(1)),
      CAST(AnlageUser AS char(15)),
      CAST(Leistung AS char(1)),
      CAST(Paketnummer AS tinyint),
      CAST(Leistungszeile AS tinyint),
      CAST(LfdBestellkontierung AS tinyint),
      CAST(SrvRetourekennzeichen AS char(1)),
      CAST(REPLACE(REPLACE(Ausgleichswert_FW_2, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(RechnBetrag_FW, N',', N'.'), N' ', N'') AS money),
      CAST(SAPRelease AS char(3)),
      CAST(CAST(REPLACE(REPLACE(Menge_3, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(CAST(REPLACE(REPLACE(MengeBPR, N',', N'.'), N' ', N'') AS float) AS int),
      CAST(REPLACE(REPLACE(Betrag_Hauswährung_2, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Betrag_2, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Bewerteter_WESperrbst_BME, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Bewerteter_WESperrbest_BPME, N',', N'.'), N' ', N'') AS money),
      CAST(Abnahme_Lieferant AS char(1)),
      CAST(REPLACE(REPLACE(Ausgleichswert_HW_2, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Kursdifferenzbetrag, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Einbehalt_Belegwährung, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Einbehalt_Buchungskreiswährung, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Gebuchter_Einbehalt_Belegwährung, N',', N'.'), N' ', N'') AS money),
      CAST(REPLACE(REPLACE(Gebuchter_Einbehalt_BW, N',', N'.'), N' ', N'') AS money),
      CAST(Mehrfachkontierung AS char(1)),
      CAST(Währungskurs AS numeric(10,3)),
      CAST(Herkunft_Rechnungsposition AS char(1)),
      CAST(Lieferung AS char(1)),
      CAST(Position_2 AS smallint),
      CAST(Bestandssegment AS char(1)),
      CAST(Logisches_System AS char(1)),
      CAST(VAkEtmg AS char(1)),
      CAST(Knz_DIE_abgeschl AS char(1)),
      CAST(Saisonjahr AS smallint),
      CAST(Saison AS char(1)),
      CAST(Kollektion AS char(1)),
      CAST(Thema AS char(1)),
      CAST(Merkmalsbezeichnung1 AS char(1)),
      CAST(Merkmalsbezeichnung2 AS char(1)),
      CAST(Merkmalsbezeichnung3 AS char(1))
    FROM EKBE_Import;

    DROP TABLE EKBE_Import;
  
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