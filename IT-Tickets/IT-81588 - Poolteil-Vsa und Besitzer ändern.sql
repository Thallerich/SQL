WITH UpdSrc AS (
  SELECT EinzTeil.ID, _IT81588.VsaID_Neu
  FROM _IT81588
  JOIN EinzTeil ON EinzTeil.Code = _IT81588.Code
  JOIN Vsa ON EinzTeil.VsaID = Vsa.ID
)
UPDATE EinzTeil SET VsaID = UpdSrc.VsaID_Neu, VsaOwnerID = IIF(VsaOwnerID > 0, UpdSrc.VsaID_Neu, EinzTeil.VsaOwnerID)
FROM UpdSrc
WHERE UpdSrc.ID = EinzTeil.ID;

GO