DECLARE @KundenID int = (SELECT ID FROM Kunden WHERE KdNr = 261012);

WITH TILAKInvLiefTag AS (
  SELECT ABT, ALST, InvTag
  FROM __TILAKInvLiefTag
  WHERE InvTag IS NOT NULL
)
UPDATE Vsa SET InvTag1 = VsaInvData.InvTag1, InvTag2 = VsaInvData.InvTag2, InvTag3 = VsaInvData.InvTag3, InvTag4 = VsaInvData.InvTag4, InvTag5 = VsaInvData.InvTag5
FROM (
  SELECT Vsa.ID AS VsaID, InvTag1 = CAST(IIF(TILAKInvLiefTag.InvTag = 1, 1, 0) AS bit), InvTag2 = CAST(IIF(TILAKInvLiefTag.InvTag = 2, 1, 0) AS bit), InvTag3 = CAST(IIF(TILAKInvLiefTag.InvTag = 3, 1, 0) AS bit), InvTag4 = CAST(IIF(TILAKInvLiefTag.InvTag = 4, 1, 0) AS bit), InvTag5 = CAST(IIF(TILAKInvLiefTag.InvTag = 5, 1, 0) AS bit)
  FROM TILAKInvLiefTag
  JOIN Vsa ON PARSENAME(REPLACE(Vsa.SuchCode, N'/', N'.'), 3) = TILAKInvLiefTag.ABT COLLATE Latin1_General_CS_AS AND PARSENAME(REPLACE(Vsa.SuchCode, N'/', N'.'), 2) = TILAKInvLiefTag.ALST COLLATE Latin1_General_CS_AS
  WHERE Vsa.KundenID = @KundenID
) VsaInvData
WHERE VsaInvData.VsaID = Vsa.ID;

GO