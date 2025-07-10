IF OBJECT_ID(N'__RechKoSofortSAPmanuell') IS NULL
BEGIN
  CREATE TABLE __RechKoSofortSAPmanuell (
    ID int PRIMARY KEY CLUSTERED
  );
END ELSE BEGIN
  TRUNCATE TABLE __RechKoSofortSAPmanuell;
END;

GO

DECLARE @RechNr TABLE (
  RechNr int
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Set table variable to specific invoice numbers!           ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
INSERT INTO @RechNr VALUES (-0815);

INSERT INTO __RechKoSofortSAPmanuell
SELECT RechKo.ID
FROM RechKo
WHERE RechKo.FibuExpID = -1
  AND RechKo.Status >= N'N'
  AND RechKo.Status < N'X'
  AND RechKo.RechNr IN (
    SELECT RechNr
    FROM @RechNr
  );

DECLARE @ExtRechNr TABLE (
  ExtRechNr nvarchar(20) COLLATE Latin1_General_CS_AS
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Set table variable to specific external invoice numbers!  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
INSERT INTO @ExtRechNr VALUES ('NON');

INSERT INTO __RechKoSofortSAPmanuell
SELECT RechKo.ID
FROM RechKo
WHERE RechKo.FibuExpID = -1
  AND RechKo.Status >= N'N'
  AND RechKo.Status < N'X'
  AND RechKo.ExtRechNr IN (
    SELECT ExtRechNr
    FROM @ExtRechNr
  );

GO

SELECT N'SAPINVOICESEND;19800101;-7;-1;__RechKoSofortSAPmanuell' AS ModuleCall;