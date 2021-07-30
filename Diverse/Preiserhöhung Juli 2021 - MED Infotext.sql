DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @PEText TABLE (
  VsaTexteID int
);

INSERT INTO VsaTexte (KundenID, TextArtID, Memo, VonDatum, BisDatum, Anlage_, AnlageUserID_, UserID_)
OUTPUT inserted.ID
INTO @PEText (VsaTexteID)
SELECT DISTINCT KundenID = Kunden.ID,
  TextArtID = 13,
  Memo = N'Wir möchten Sie informieren, dass die Festlegung des Paritätischen Preisantrages zur Erhöhung in diesem Jahr, im September 2021 erfolgen wird und wir daher rückwirkend mit 1. Juli 2021 die Nachverrechnung durchführen werden.',
  VonDatum = CAST(N'2021-07-30' AS date),
  BisDatum = CAST(N'2021-08-16' AS date),
  Anlage_ = GETDATE(),
  AnlageUserID_ = @UserID,
  UserID_ = @UserID
FROM PePo
JOIN Vertrag ON PePo.VertragID = Vertrag.ID
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
WHERE PePo.PeKoID IN (487, 492)
  AND KdGf.KurzBez = N'MED'
  AND PePo.PeProzent != 0;

SELECT KdGf.KurzBez AS KdGf, Kunden.KdNr, Kunden.SuchCode, ABC.ABCBez AS [ABC-Klassifizierung], VsaTexte.VonDatum, VsaTexte.BisDatum, VsaTexte.Memo AS [Fakturatext Fuß]
FROM @PEText AS PEText
JOIN VsaTexte ON PEText.VsaTexteID = VsaTexte.ID
JOIN Kunden ON VsaTexte.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN ABC ON Kunden.AbcID = ABC.ID;

GO