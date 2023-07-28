DECLARE @ChargeNr int = 80000060; /* Nummer der Pseudocharge */
DECLARE @Standort nchar(4) = N'UKL5'; /* Kürzel des OP-Standorts - möglich: WOE5 (Enns), UKL5 (Klagenfurt), SAWR (Wr. Neustadt) */

DECLARE @StandortID int;

SELECT @StandortID = Standort.ID
FROM Standort
WHERE Standort.SuchCode = @Standort
  AND EXISTS (
    SELECT OPCharge.*
    FROM OPCharge
    WHERE OPCharge.StandortID = Standort.ID
      AND OPCharge.Pseudo = 1
  );

IF @StandortID IS NULL
  RAISERROR(N'Falsches Standortkürzel', 1, 0) WITH NOWAIT;
ELSE
  UPDATE OPCharge SET OPSteriChargeID = -1
  WHERE OPCharge.ChargeNr = @ChargeNr
    AND OPCharge.Pseudo = 1
    AND OPCharge.StandortID = @StandortID
    AND OPSteriChargeID > 0;