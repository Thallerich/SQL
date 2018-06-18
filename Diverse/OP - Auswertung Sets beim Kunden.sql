SELECT OPEtiKo.EtiNr, Status.StatusBez AS [aktueller Status], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, OPEtiKo.DruckZeitpunkt, OPEtiKo.PackZeitpunkt, OpCharge.Zeitpunkt AS [SterilZeitpunkt], OPEtiKo.AusleseZeitpunkt
FROM OPEtiKo
JOIN Vsa ON OPEtiKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN [Status] ON OPEtiKo.Status = [Status].[Status] AND [Status].Tabelle = N'OPETIKO'
JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID
JOIN OPCharge ON OPEtiKo.OPChargeID = OPCharge.ID
WHERE Kunden.StandortID = (SELECT Standort.ID FROM Standort WHERE Standort.Bez = N'Rankweil')
  AND OPEtiKo.Status = N'R'
  AND OPEtiKo.ArtikelID IN (
    SELECT OPSets.ArtikelID
    FROM OPSets
    JOIN Artikel ON OPSets.Artikel1ID = Artikel.ID
    JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
    WHERE ArtGru.Barcodiert = 1
  )
  AND EXISTS (
    SELECT OPEtiPo.*
    FROM OPEtiPo
    WHERE OPEtiPo.OPEtiKoID = OPEtiKo.ID
  );