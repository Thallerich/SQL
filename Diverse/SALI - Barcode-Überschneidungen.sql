SELECT Nummer_von, Nummer_bis, Zeichenlänge, COUNT(DISTINCT TeileID) AS CodesWozabal
FROM (
  SELECT _BCKreisSAL.Nummer_von, _BCKreisSAL.Nummer_bis, _BCKreisSAL.Zeichenlänge, N'TEILE_' + CAST(Teile.ID AS nvarchar(20)) AS TeileID
  FROM _BCKreisSAL
  INNER JOIN Teile ON Teile.Barcode >= RIGHT(REPLICATE(N'0', _BCKreisSAL.Zeichenlänge) + LTRIM(RTRIM(_BCKreisSAL.Nummer_von)), _BCKreisSAL.Zeichenlänge) COLLATE Latin1_General_CS_AS
    AND Teile.Barcode <= RIGHT(REPLICATE(N'0', _BCKreisSAL.Zeichenlänge) + LTRIM(RTRIM(_BCKreisSAL.Nummer_bis)), _BCKreisSAL.Zeichenlänge) COLLATE Latin1_General_CS_AS
    AND LEN(Teile.Barcode) = _BCKreisSAL.Zeichenlänge

  UNION ALL

  SELECT _BCKreisSAL.Nummer_von, _BCKreisSAL.Nummer_bis, _BCKreisSAL.Zeichenlänge, N'TEILE_' + CAST(Teile.ID AS nvarchar(20)) AS TeileID
  FROM _BCKreisSAL
  INNER JOIN Teile ON Teile.RentomatChip >= RIGHT(REPLICATE(N'0', _BCKreisSAL.Zeichenlänge) + LTRIM(RTRIM(_BCKreisSAL.Nummer_von)), _BCKreisSAL.Zeichenlänge) COLLATE Latin1_General_CS_AS
    AND Teile.RentomatChip <= RIGHT(REPLICATE(N'0', _BCKreisSAL.Zeichenlänge) + LTRIM(RTRIM(_BCKreisSAL.Nummer_bis)), _BCKreisSAL.Zeichenlänge) COLLATE Latin1_General_CS_AS
    AND LEN(Teile.RentomatChip) = _BCKreisSAL.Zeichenlänge

  UNION ALL

  SELECT _BCKreisSAL.Nummer_von, _BCKreisSAL.Nummer_bis, _BCKreisSAL.Zeichenlänge, N'OPTEILE_' + CAST(OPTeile.ID AS nvarchar(20)) AS TeileID
  FROM _BCKreisSAL
  INNER JOIN OPTeile ON OPTeile.Code >= RIGHT(REPLICATE(N'0', _BCKreisSAL.Zeichenlänge) + LTRIM(RTRIM(_BCKreisSAL.Nummer_von)), _BCKreisSAL.Zeichenlänge) COLLATE Latin1_General_CS_AS
    AND OPTeile.Code <= RIGHT(REPLICATE(N'0', _BCKreisSAL.Zeichenlänge) + LTRIM(RTRIM(_BCKreisSAL.Nummer_bis)), _BCKreisSAL.Zeichenlänge) COLLATE Latin1_General_CS_AS
    AND LEN(OPTeile.Code) = _BCKreisSAL.Zeichenlänge

  UNION ALL

  SELECT _BCKreisSAL.Nummer_von, _BCKreisSAL.Nummer_bis, _BCKreisSAL.Zeichenlänge, N'OPTEILE_' + CAST(OPTeile.ID AS nvarchar(20)) AS TeileID
  FROM _BCKreisSAL
  INNER JOIN OPTeile ON OPTeile.Code2 >= RIGHT(REPLICATE(N'0', _BCKreisSAL.Zeichenlänge) + LTRIM(RTRIM(_BCKreisSAL.Nummer_bis)), _BCKreisSAL.Zeichenlänge) COLLATE Latin1_General_CS_AS
    AND OPTeile.Code2 <= RIGHT(REPLICATE(N'0', _BCKreisSAL.Zeichenlänge) + LTRIM(RTRIM(_BCKreisSAL.Nummer_bis)), _BCKreisSAL.Zeichenlänge) COLLATE Latin1_General_CS_AS
    AND LEN(OPTeile.Code2) = _BCKreisSAL.Zeichenlänge
) AS BCKreis
GROUP BY Nummer_von, Nummer_bis, Zeichenlänge
ORDER BY Nummer_von ASC;