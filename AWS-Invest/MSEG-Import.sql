USE AWSInvest;
GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    INSERT INTO MSEG (Materialbeleg, Materialbelegjahr, Materialbelegposition, Bewegungsart, Material, Werk, Lagerort, Charge, Lieferant, Kunde, Kundenauftrag, Kundenauftragposition, Kundenauftrag_Eint, KZSollHaben, Währung, BetragHauswährung, Bezugsnebenkosten, Betrag, Menge, BasisME, Menge_ErfassME, ErfassME, Menge_BPME, BPME, Bestellung, Bestellposition, RefBeleg_Geschäftsjahr, RefBeleg, RefBeleg_Position, MatBeleg_Jahr, MatBeleg, MatBeleg_Position, Endlieferung, Memotext, Warenempfänger, Abladestelle, Geschäftsbereich, PartnerGeschäftsbereich, Kostenstelle, Geschäftsjahr, RückbuchungErlaubt, RückbuchenVorjahr, Buchungskreis, Belegnummer, Belegposition, Belegnummer2, Belegpositon2, Reservierung, ReservierungPosition, Endausgefasst, Menge2, StatistikRelevant, MaterialEmfpänger, WerkEmpfänger, LagerortEmfpänger, Sachkonto, Menge_BestellME, BestellME, WESt_trotz_RE, Lieferant2, BetragExt_Hauswährung, VKWertBrutto, Aktion, LfdKontierung, Bestandsmaterial, EmpfMaterial, Mengenstring, Wertestring, Mengenfortschreibung, Wertfortschreibung, BestandBewertet, GesamtwertVorBuchung, Kundenauftrag2, Kundenauftrag2position, Vorgangsart, Buchungsdatum, Erfassungsdatum, Erfassungszeit, Benutzername, Referenz, Transaktionscode, Lieferung, LieferungPosition, Änderungsgrund, Branche)
    SELECT CAST(Materialbeleg AS char(15)) AS Materialbeleg,
      CAST(Materialbelegjahr AS smallint) AS Materialbelegjahr,
      CAST(Materialbelegposition AS smallint) AS Materialbelegposition,
      CAST(Bewegungsart AS smallint) AS Bewegungsart,
      CAST(Material AS nchar(20)) AS Material,
      CAST(Werk AS char(4)) AS Werk,
      CAST(Lagerort AS char(4)) AS Lagerort,
      CAST(Charge AS char(1)) AS Charge,
      CAST(Lieferant AS int) AS Lieferant,
      CAST(Kunde AS int) AS Kunde,
      CAST(Kundenauftrag AS char(15)) AS Kundenauftrag,
      CAST(Kundenauftragposition AS smallint) AS Kundenauftragposition,
      CAST(Kundenauftrag_Eint AS tinyint) AS Kundenauftrag_Eint,
      CAST(KZSollHaben AS char(1)) AS KZSollHaben,
      CAST(Währung AS char(3)) AS Währung,
      CAST(REPLACE(REPLACE(BetragHauswährung, N',', N'.'), N' ', N'') AS money) AS BetragHauswährung,
      CAST(REPLACE(REPLACE(Bezugsnebenkosten, N',', N'.'), N' ', N'') AS money) AS Bezugsnebenkosten,
      CAST(Betrag AS money) AS Betrag,
      CAST(CAST(REPLACE(REPLACE(Menge, N',', N'.'), N' ', N'') AS float) AS int) AS Menge,
      CAST(BasisME AS char(3)) AS BasisME,
      CAST(CAST(REPLACE(REPLACE(Menge_ErfassME, N',', N'.'), N' ', N'') AS float) AS int) AS Menge_ErfassME,
      CAST(ErfassME AS char(3)) AS ErfassME,
      CAST(CAST(REPLACE(REPLACE(Menge_BPME, N',', N'.'), N' ', N'') AS float) AS int) AS Menge_BPME,
      CAST(BPME AS char(3)) AS BPME,
      CAST(Bestellung AS bigint) AS Bestellung,
      CAST(Bestellposition AS int) AS Bestellposition,
      CAST(RefBeleg_Geschäftsjahr AS smallint) AS RefBeleg_Geschäftsjahr,
      TRY_CAST(RefBeleg AS bigint) AS RefBeleg,
      CAST(RefBeleg_Position AS smallint) AS RefBeleg_Position,
      CAST(MatBeleg_Jahr AS smallint) AS MatBeleg_Jahr,
      CAST(MatBeleg AS bigint) AS MatBeleg,
      CAST(MatBeleg_Position AS smallint) AS MatBeleg_Position,
      CAST(Endlieferung AS char(1)) AS Endlieferung,
      Memotext,
      CAST(Warenempfänger AS char(15)) AS Warenempfänger,
      CAST(Abladestelle AS char(20)) AS Abladestelle,
      CAST(Geschäftsbereich AS char(4)) AS Geschäftsbereich,
      CAST(PartnerGeschäftsbereich AS char(4)) AS PartnerGeschäftsbereich,
      CAST(Kostenstelle AS char(15)) AS Kostenstelle,
      CAST(Geschäftsjahr AS smallint) AS Geschäftsjahr,
      RückbuchungErlaubt = CASE RückbuchungErlaubt WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      RückbuchenVorjahr = CASE RückbuchenVorjahr WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(Buchungskreis AS smallint) AS Buchungskreis,
      CAST(Belegnummer AS bigint) AS Belegnummer,
      CAST(Belegposition AS smallint) AS Belegposition,
      CAST(Belegnummer2 AS bigint) AS Belegnummer2,
      CAST(Belegpositon2 AS smallint) AS Belegpositon2,
      CAST(Reservierung AS bigint) AS Reservierung,
      CAST(ReservierungPosition AS smallint) AS ReservierungPosition,
      Endausgefasst = CASE Endausgefasst WHEN N'X' THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
      CAST(CAST(REPLACE(REPLACE(Menge2, N',', N'.'), N' ', N'') AS float) AS int) AS Menge2,
      CAST(StatistikRelevant AS tinyint) AS StatistikRelevant,
      CAST(MaterialEmfpänger AS nchar(20)) AS MaterialEmfpänger,
      CAST(WerkEmpfänger AS char(4)) AS WerkEmpfänger,
      CAST(LagerortEmfpänger AS char(4)) AS LagerortEmfpänger,
      CAST(Sachkonto AS int) AS Sachkonto,
      CAST(CAST(REPLACE(REPLACE(Menge_BestellME, N',', N'.'), N' ' , N'') AS float) AS int) AS Menge_BestellME,
      CAST(BestellME AS char(3)) AS BestellME,
      CAST(WESt_trotz_RE AS char(1)) AS WESt_trotz_RE,
      CAST(Lieferant2 AS int) AS Lieferant2,
      CAST(REPLACE(REPLACE(BetragExt_Hauswährung, N',', N'.'), N' ', N'') AS money) AS BetragExt_Hauswährung,
      CAST(REPLACE(REPLACE(VKWertBrutto, N',', N'.'), N' ', N'') AS money) AS VKWertBrutto,
      CAST(Aktion AS char(1)) AS Aktion,
      CAST(LfdKontierung AS bit) AS LfdKontierung,
      CAST(Bestandsmaterial AS nchar(20)) AS Bestandsmaterial,
      CAST(EmpfMaterial AS nchar(20)) AS EmpfMaterial,
      CAST(Mengenstring AS char(4)) AS Mengenstring,
      CAST(Wertestring AS char(4)) AS Wertestring,
      CAST(Mengenfortschreibung AS char(1)) AS Mengenfortschreibung,
      CAST(Wertfortschreibung AS char(1)) AS Wertfortschreibung,
      CAST(REPLACE(REPLACE(BestandBewertet, N',', N'.'), N' ', N'') AS int) AS BestandBewertet,
      CAST(REPLACE(REPLACE(GesamtwertVorBuchung, N',', N'.'), N' ', N'') AS money) AS GesamtwertVorBuchung,
      CAST(Kundenauftrag2 AS char(15)) AS Kundenauftrag2,
      CAST(Kundenauftrag2position AS smallint),
      CAST(Vorgangsart AS char(2)) AS Vorgangsart,
      CONvERT(date, Buchungsdatum, 104) AS Buchungsdatum,
      CONVERT(date, Erfassungsdatum, 104) AS Erfassungsdatum,
      CAST(Erfassungszeit AS time) AS Erfassungszeit,
      CAST(Benutzername AS char(15)) AS Benutzername,
      CAST(Referenz AS nchar(20)) AS Referenz,
      CAST(Transaktionscode AS char(10)) AS Transaktionscode,
      CAST(Lieferung AS bigint) AS Lieferung,
      CAST(LieferungPosition AS smallint) AS LieferungPosition,
      CAST(Änderungsgrund AS char(10)) AS Änderungsgrund,
      CAST(Branche AS char(4)) AS Branche
    FROM MSEG_Import;
    
    DROP TABLE MSEG_Import;
  
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