SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Status.StatusBez AS Kundenstatus, VsaTexte.VonDatum, VsaTexte.BisDatum, TextArt.TextArtBez$LAN$ AS Textart, VsaTexte.Memo AS Memotext
FROM VsaTexte, Kunden, KdGf, TextArt, (SELECT Status.Status, Status.StatusBez$LAN$ AS StatusBez FROM Status WHERE Status.Tabelle = 'KUNDEN') AS Status
WHERE VsaTexte.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Kunden.Status = Status.Status
  AND VsaTexte.TextArtID = TextArt.ID
  AND KdGf.ID IN ($1$)
  AND VsaTexte.BisDatum >= CONVERT(date, GETDATE());