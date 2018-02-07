SELECT Betriebsteil, Startwert, Endwert, Länge, COUNT(DISTINCT TeileID) AS CodesWozabal
FROM (
  SELECT _idbereiche_sal.Betriebsteil, _idbereiche_sal.Startwert, _idbereiche_sal.Endwert, _idbereiche_sal.Länge, N'TEILE_' + CAST(Teile.ID AS nvarchar(20)) AS TeileID
  FROM _idbereiche_sal
  INNER JOIN Teile ON Teile.Barcode >= RIGHT(REPLICATE(N'0', _idbereiche_sal.Länge) + LTRIM(RTRIM(_idbereiche_sal.Startwert)), _idbereiche_sal.Länge) COLLATE Latin1_General_CS_AS
    AND Teile.Barcode <= RIGHT(REPLICATE(N'0', _idbereiche_sal.Länge) + LTRIM(RTRIM(_idbereiche_sal.Endwert)), _idbereiche_sal.Länge) COLLATE Latin1_General_CS_AS
    AND LEN(Teile.Barcode) = _idbereiche_sal.Länge

  UNION ALL

  SELECT _idbereiche_sal.Betriebsteil, _idbereiche_sal.Startwert, _idbereiche_sal.Endwert, _idbereiche_sal.Länge, N'TEILE_' + CAST(Teile.ID AS nvarchar(20)) AS TeileID
  FROM _idbereiche_sal
  INNER JOIN Teile ON Teile.RentomatChip >= RIGHT(REPLICATE(N'0', _idbereiche_sal.Länge) + LTRIM(RTRIM(_idbereiche_sal.Startwert)), _idbereiche_sal.Länge) COLLATE Latin1_General_CS_AS
    AND Teile.RentomatChip <= RIGHT(REPLICATE(N'0', _idbereiche_sal.Länge) + LTRIM(RTRIM(_idbereiche_sal.Endwert)), _idbereiche_sal.Länge) COLLATE Latin1_General_CS_AS
    AND LEN(Teile.RentomatChip) = _idbereiche_sal.Länge

  UNION ALL

  SELECT _idbereiche_sal.Betriebsteil, _idbereiche_sal.Startwert, _idbereiche_sal.Endwert, _idbereiche_sal.Länge, N'OPTEILE_' + CAST(OPTeile.ID AS nvarchar(20)) AS TeileID
  FROM _idbereiche_sal
  INNER JOIN OPTeile ON OPTeile.Code >= RIGHT(REPLICATE(N'0', _idbereiche_sal.Länge) + LTRIM(RTRIM(_idbereiche_sal.Startwert)), _idbereiche_sal.Länge) COLLATE Latin1_General_CS_AS
    AND OPTeile.Code <= RIGHT(REPLICATE(N'0', _idbereiche_sal.Länge) + LTRIM(RTRIM(_idbereiche_sal.Endwert)), _idbereiche_sal.Länge) COLLATE Latin1_General_CS_AS
    AND LEN(OPTeile.Code) = _idbereiche_sal.Länge

  UNION ALL

  SELECT _idbereiche_sal.Betriebsteil, _idbereiche_sal.Startwert, _idbereiche_sal.Endwert, _idbereiche_sal.Länge, N'OPTEILE_' + CAST(OPTeile.ID AS nvarchar(20)) AS TeileID
  FROM _idbereiche_sal
  INNER JOIN OPTeile ON OPTeile.Code2 >= RIGHT(REPLICATE(N'0', _idbereiche_sal.Länge) + LTRIM(RTRIM(_idbereiche_sal.Endwert)), _idbereiche_sal.Länge) COLLATE Latin1_General_CS_AS
    AND OPTeile.Code2 <= RIGHT(REPLICATE(N'0', _idbereiche_sal.Länge) + LTRIM(RTRIM(_idbereiche_sal.Endwert)), _idbereiche_sal.Länge) COLLATE Latin1_General_CS_AS
    AND LEN(OPTeile.Code2) = _idbereiche_sal.Länge
) AS BCKreis
GROUP BY Betriebsteil, Startwert, Endwert, Länge
ORDER BY Betriebsteil, Länge, Startwert ASC;