DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

MERGE INTO PLZ USING (
  SELECT _PLZVerzeichnis.PLZ,
    _PLZVerzeichnis.Ort,
    _BuLand.ID AS BuLandID,
    _PLZVerzeichnis.gueltigab,
    _PLZVerzeichnis.gueltigbis,
    _PlzTyp.ID AS PlzTypID,
    Adressierbar = 
      CASE _PLZVerzeichnis.adressierbar
        WHEN N'Ja' THEN CAST(1 AS bit) 
        ELSE CAST(0 AS bit)
      END,
    Postfach = CASE _PLZVerzeichnis.Postfach
        WHEN N'Ja' THEN CAST(1 AS bit)
        ELSE CAST(0 AS bit)
      END
  FROM _PLZVerzeichnis
  JOIN _BuLand ON _BuLand._Kuerzel = CASE _PLZVerzeichnis.Bundesland
        WHEN N'W' THEN N'W'
        WHEN N'B' THEN N'Bgld.'
        WHEN N'K' THEN N'Ktn.'
        WHEN N'N' THEN N'NÖ'
        WHEN N'O' THEN N'OÖ'
        WHEN N'Sa' THEN N'Sbg.'
        WHEN N'St' THEN N'Stmk.'
        WHEN N'T' THEN N'T'
        WHEN N'V' THEN N'Vbg.'
      END
  JOIN _PLZTyp ON _PLZTyp._PLZTypBez = CASE _PLZVerzeichnis.PLZTyp
        WHEN N'FeldPLZ' THEN N'Feld-PLZ'
        WHEN N'InteressentenPLZ' THEN N'Interessenten-PLZ'
        WHEN N'PLZ-Adressierung' THEN N'PLZ-Adressierung'
        WHEN N'PLZ-Historisch' THEN N'PLZ-Historisch'
        WHEN N'PLZ-Postfach' THEN N'PLZ-Postfach'
      END
) AS PLZSource (PLZ, Ort, BuLandID, gueltigab, gueltigbis, PlzTypID, adressierbar, Postfach)
ON PLZ.PLZ = PLZSource.PLZ AND PLZ.Land = N'AT'
WHEN MATCHED THEN
  UPDATE SET Ort = PLZSource.Ort, _BuLandID = PLZSource.BuLandID, _GueltigAb = PLZSource.gueltigab, _GueltigBis = PLZSource.gueltigbis, _PLZTypID = PLZSource.PLZTypID, _Adressierbar = PLZSource.Adressierbar, _Postfach = PLZSource.Postfach
WHEN NOT MATCHED THEN
  INSERT (PLZ, Ort, Land, AnlageUserID_, UserID_, _BuLandID, _GueltigAb, _GueltigBis, _PLZTypID, _Adressierbar, _Postfach)
  VALUES (PLZSource.PLZ, PLZSource.Ort, N'AT', @UserID, @UserID, PLZSource.BuLandID, PLZSource.gueltigab, PLZSource.gueltigbis, PLZSource.PlzTypID, PLZSource.Adressierbar, PLZSource.Postfach);