SELECT WegGrund.ID,
  WegGrund.WegGrundBez,
  WegGrund.Austausch,
  WegGrund.Schrott AS Verschrottung,
  WegGrund.OPSchrott AS [Verschrottung in OP-Versorgung],
  WegGrund.TPSSchrott AS [Verschrottung TP-Strümpfe],
  WegGrund.IsAutoWeggrund AS [wird automatisch verwendet],
  WegGrund.OPNachwaesche AS [Nachwäsche-Grund in OP-Versorgung],
  WegGrund.OPUnsteril AS [Unsteril im OP-Bereich],
  WegGrund.Gutschrift AS Gutschrift,
  WegGrund.Reklamation,
  WegGrund.NoService AS [No-Service (PDA)],
  WegGrund.NoSignature AS [No-NoSignature (PDA)],
  WegGrund.NoBarcode AS [No-Barcode (PDA],
  WegGrund.Wareneingang AS [im Wareneingang auswählbar],
  WegGrund.AustauschWeb AS [Austausch im Webportal],
  WegGrund.RwBerechnenSchlRueckg AS [Restwert berechnen für schlechte Rückgaben],
  IIF(LsKoGru.ID > 0, LsKoGru.LskoGruBez, NULL) AS Lieferscheingrund
FROM WegGrund
JOIN LsKoGru ON WegGrund.LsKoGruID = LsKoGru.ID
WHERE WegGrund.ID > 0;