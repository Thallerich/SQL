USE Wozabal;

SELECT _ZBSAP.ZBNr, ZahlZiel.*
FROM _ZBSAP
JOIN ZahlZiel ON _ZBSAP.SkontoTage1 = ZahlZiel.SkontoTage AND _ZBSAP.Skonto1 = ZahlZiel.Skonto AND _ZBSAP.SkontoTage2 = ZahlZiel.SkontoTage2 AND _ZBSAP.Skonto2 = ZahlZiel.Skonto2 AND _ZBSAP.NettoTage = ZahlZiel.NettoTage
WHERE ZahlZiel.ID > 0
  AND ZahlZiel.Kunden = 1
ORDER BY _ZBSAP.ZBNr ASC;

/*
UPDATE ZahlZiel SET ZahlZiel.ZahlZiel = RTRIM(_ZBSAP.ZBNr)
FROM _ZBSAP
JOIN ZahlZiel ON _ZBSAP.SkontoTage1 = ZahlZiel.SkontoTage AND _ZBSAP.Skonto1 = ZahlZiel.Skonto AND _ZBSAP.SkontoTage2 = ZahlZiel.SkontoTage2 AND _ZBSAP.Skonto2 = ZahlZiel.Skonto2 AND _ZBSAP.NettoTage = ZahlZiel.NettoTage
WHERE ZahlZiel.ID > 0
  AND ZahlZiel.Kunden = 1;
*/