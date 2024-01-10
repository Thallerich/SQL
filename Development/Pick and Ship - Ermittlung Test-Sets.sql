SET NOCOUNT ON;
GO

USE Salesianer_Test
GO

DECLARE @OPAblauf int = (SELECT CAST(ValueMemo AS int) FROM Settings WHERE Parameter = N'OP_ZU_PACKZETTEL_VOR_ABLAUF');

WITH Chargenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'OPCHARGE'
)
SELECT TOP 10 Kunden.KdNr, Vsa.VsaNr, Vsa.Bez, OPEtiKo.EtiNr, OPEtiKo.[Status], OPEtiKo.VerfallDatum, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGru.Gruppe, ArtGru.Steril, OPCharge.ChargeNr, OPcharge.ChargeDatum, Chargenstatus.StatusBez AS [Status Steril-Charge]
FROM OPEtiKo
JOIN Vsa ON OPEtiKo.PackVsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN OPCharge ON OPEtiKo.OPChargeID = OPCharge.ID
JOIN Chargenstatus ON OPCharge.[Status] = Chargenstatus.[Status]
WHERE OPEtiKo.[Status] = N'M'
  AND DATEADD(day, @OPAblauf * -1, OPEtiKo.VerfallDatum) > CAST(GETDATE() AS date)
  AND OPEtiKo.PackVsaID > 0;

GO