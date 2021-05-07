/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Detail-Auswertung, für welche Container Miete fakturiert wurde, weil diese mehr als 28 Tage beim Kunden waren             ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2021-05-07                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @RechKoID int = (SELECT RechKo.ID FROM RechKo WHERE RechKo.RechNr = 30099861);
DECLARE @KundenID int = (SELECT RechKo.KundenID FROM RechKo WHERE ID = @RechKoID);
DECLARE @LeasingVon date = (SELECT RechKo.VonDatum FROM RechKo WHERE ID = @RechKoID);
DECLARE @LeasingBis date = (SELECT RechKo.BisDatum From RechKo WHERE ID = @RechKoID);

DECLARE @KundenCont TABLE (
  ContainID int,
  KundenID int,
  VsaID int,
  Abladezeit datetime2 DEFAULT NULL,
  Abholzeit datetime2 DEFAULT NULL
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Zum Kunden ausgelieferte Container ermitteln                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
INSERT INTO @KundenCont (ContainID, KundenID, VsaID, Abladezeit)
SELECT ContHist.ContainID, ContHist.KundenID, ContHist.VsaID, ContHist.Zeitpunkt AS Abladezeit
FROM ContHist
JOIN Kunden ON ContHist.KundenID = Kunden.ID
WHERE ContHist.Status = N'e'
  AND Kunden.ID = @KundenID;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Abholzeitpunkt der Container anhand nächstem Scan ermitteln                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
WITH ContRetour AS (
  SELECT ContHist.ContainID, KundenCont.Abladezeit, MIN(ContHist.Zeitpunkt) AS Abholzeit
  FROM ContHist
  JOIN @KundenCont AS KundenCont ON ContHist.ContainID = KundenCont.ContainID
  WHERE ContHist.Zeitpunkt > KundenCont.Abladezeit
  GROUP BY ContHist.ContainID, KundenCont.Abladezeit
)
UPDATE @KundenCont SET Abholzeit = ContRetour.Abholzeit
FROM @KundenCont AS KundenCont
JOIN ContRetour ON ContRetour.ContainID = KundenCont.ContainID AND ContRetour.Abladezeit = KundenCont.Abladezeit;

SELECT Contain.Barcode, Kunden.KdNr, Kunden.SuchCode AS Kunde, KundenCont.Abladezeit, KundenCont.Abholzeit
FROM @KundenCont AS KundenCont
JOIN Contain ON KundenCont.ContainID = Contain.ID
JOIN Kunden ON KundenCont.KundenID = Kunden.ID
WHERE DATEDIFF(day, KundenCont.Abladezeit, IIF(ISNULL(KundenCont.Abholzeit, GETDATE()) > @LeasingBis, @LeasingBis, KundenCont.Abholzeit)) >= 28
  AND ISNULL(KundenCont.Abholzeit, GETDATE()) > @LeasingVon;