-- SH-Wäscherei Enns - Startsignal manuell

-- SH-Wäscherei VSAs (Report-Parameter)
SELECT Vsa.ID, CONVERT(Kunden.KdNr, SQL_VARCHAR) + ' ' + TRIM(Kunden.SuchCode) + ' | ' + TRIM(Vsa.SuchCode) + ' ' + TRIM(Vsa.Bez) AS Text
FROM Vsa, Kunden, VsaBer, KdBer, Bereich
WHERE Vsa.KundenID = Kunden.ID
  AND VsaBer.VsaID = Vsa.ID
  AND VsaBer.KdBerID = KdBer.ID
  AND KdBer.BereichID = Bereich.ID
  AND Bereich.ID IN (SELECT Bereich.ID FROM Bereich WHERE LogistikKonzKG = TRUE)
ORDER BY Text ASC;

-- Ziel-Liste (Report-Parameter)
SELECT ZielNr.Bez
FROM ZielNr
WHERE ZielNr.ID IN (10000038, 10000040, 10000041, 10000042, 10000043, 10000044, 10000045);

-- INSERT-Befehl (Startsignal in DB)
INSERT INTO KG0001 VALUES (1, $2$ /*Zielname*/, $1$ /*Vsa.ID*/, FALSE, FALSE, -1, -1, NULL, NOW(), NULL, NULL);
SELECT 'Senden OK' FROM System.IOTA;