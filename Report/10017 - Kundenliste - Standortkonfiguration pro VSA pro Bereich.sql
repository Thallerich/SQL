SELECT KdNr = Kunden.KdNr,
       [Kunde Stichwort] = Kunden.SuchCode,
       [Kunde Name 1] = Kunden.Name1,
       [Kunde Name 2] = Kunden.Name2,
       [Kunde Name 3] = Kunden.Name3,
       [Kunde Straße] = Kunden.Strasse,
       [Kunde PLZ] = Kunden.PLZ,
       [Kunde Ort] = Kunden.Ort,
       [Kunde Land] = Kunden.Land,
       VsaNr = Vsa.VsaNr,
       [Vsa Stichwort] = Vsa.SuchCode,
       [Vsa Bezeichnung] = Vsa.Bez,
       [Vsa Name 1] = Vsa.Name1,
       [Vsa Name 2] = Vsa.Name2,
       [Vsa Name 3] = Vsa.Name3,
       [Vsa Straße] = Vsa.Strasse,
       [Vsa PLZ] = Vsa.PLZ,
       [Vsa Ort] = Vsa.Ort,
       [Vsa Land] = Vsa.Land,
       Produktbereich = Bereich.BereichBez,
       Produktion = Produktion.Bez,
       Expedition = Expedition.Bez,
       Kundendienst = Kundendienst.Bez,
       [lokales Lager] = LokalLager.Bez,
       Lager = Lager.Bez
FROM VsaBer
JOIN Vsa ON VsaBer.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND Bereich.ID = StandBer.BereichID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Expedition ON StandBer.ExpeditionID = Expedition.ID
JOIN Standort AS Kundendienst ON StandBer.KundendienstID = Kundendienst.ID
JOIN Standort AS LokalLager ON StandBer.LokalLagerID = LokalLager.ID
JOIN Standort AS Lager ON StandBer.LagerID = Lager.ID
WHERE Kunden.[Status] = 'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.ID > 0
  AND Kunden.FirmaID IN ($1$)
  AND Kunden.KdGfID IN ($2$)
  AND StandBer.StandKonID IN ($3$)
ORDER BY Kunden.KdNr, Vsa.VsaNr;