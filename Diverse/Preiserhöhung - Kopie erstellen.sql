DECLARE @PeNew TABLE (
  PeKoID int
);

DECLARE @PeKoID int = 679;
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO PeKo (ProzVorschlag, Bez, [Status], DurchfuehrungsDatum, DurchfuehrungMitarbeiID, AnkuendDatum, AnkuendMitarbeiID, WirksamDatum, Memo, AnzVertraege, KundenSelektion, MonatUmsatzBer, MinVertragAlter, MinSeitLetzterPE, MinBisVertragEnde, FirmenIDs, StandortIDs, KdGfIDs, BereichIDs, KuendFraglErhoehen, KuendNichtFraglErhoehen, Leasingpreis, Waschpreis, VKPreis, Basisrestwert, Sonderpreis, PrLaufID, AnlageUserID_, UserID_)
OUTPUT inserted.ID
INTO @PeNew (PeKoID)
SELECT ProzVorschlag, Bez + N' __2' AS Bez, N'C' AS [Status], NULL AS DurchfuehrungsDatum, -1 AS DurchfuehrungMitarbeiID, NULL AS AnkuendDatum, -1 AS AnkuendMitarbeiID, WirksamDatum, Memo, AnzVertraege, KundenSelektion, MonatUmsatzBer, MinVertragAlter, MinSeitLetzterPE, MinBisVertragEnde, FirmenIDs, StandortIDs, KdGfIDs, BereichIDs, KuendFraglErhoehen, KuendNichtFraglErhoehen, Leasingpreis, Waschpreis, VKPreis, Basisrestwert, Sonderpreis, PrLaufID, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM PeKo
WHERE ID = @PeKoID;

INSERT INTO PePo (PeKoID, VertragID, KuendGruID, [Status], PeProzent, AnkuendProzent, CaJahresumsatz, AnlageProzent, AnlageKuendGruID, Umsatz01, Umsatz02, Umsatz03, Umsatz04, Umsatz05, Umsatz06, Umsatz07, Umsatz08, Umsatz09, Umsatz10, Umsatz11, Umsatz12, PeBasisEffektiv, PeBasisLeasing, PeBasisGesamt, AnlageUserID_, UserID_)
SELECT PeNew.PeKoID, VertragID, KuendGruID, N'A' AS [Status], PeProzent, AnkuendProzent, CaJahresumsatz, AnlageProzent, AnlageKuendGruID, Umsatz01, Umsatz02, Umsatz03, Umsatz04, Umsatz05, Umsatz06, Umsatz07, Umsatz08, Umsatz09, Umsatz10, Umsatz11, Umsatz12, PeBasisEffektiv, PeBasisLeasing, PeBasisGesamt, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM PePo
CROSS JOIN @PeNew AS PeNew
WHERE PePo.PeKoID = @PeKoID;