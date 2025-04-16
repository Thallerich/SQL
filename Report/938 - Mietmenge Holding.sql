SELECT
  [Produzierender Betrieb] = Expedition.Bez,
  [Intern produzierender Betrieb] = Produktion.Bez,
  Kette = Holding.Holding,
  Kundennummer = Kunden.KdNr,
  Kunde = Kunden.SuchCode,
  [VSA-Nummer] = Vsa.VsaNr,
  [VSA-Stichwort] = Vsa.Suchcode,
  [VSA-Bezeichnung] = Vsa.Bez,
  [VSA-Adresszeile 1] = Vsa.Name1,
  [VSA-Adresszeile 2] = Vsa.Name2,
  Gebäude = Vsa.GebaeudeBez,
  Kostenstelle = Abteil.Abteilung,
  Kostenstellenbezeichnung = Abteil.Bez,
  [Externe Bestellnummer] = CAST(LEFT(Abteil.RechnungsMemo, 200) AS nvarchar(200)),
  Produktbereich = Bereich.BereichBez$LAN$,
  Produktgruppe = ArtGru.Gruppe,
  Produkt = Artikel.ArtikelNr,
  Produktbeschreibung = Artikel.ArtikelBez$LAN$,
  Größe = ArtGroe.Groesse,
  Mietmenge = SUM(COALESCE(TraeArch.Menge, AbtKdArW.Menge)),
  Kalenderwoche = Wochen.Woche,
  [Leasingpreis] = KdArti.LeasPreis,
  [Bearbeitungspreis] = KdArti.Waschpreis
FROM AbtKdArW
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN Abteil ON AbtKdArW.AbteilID = Abteil.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON AbtKdArW.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Bereich.ID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Expedition ON StandBer.ExpeditionID = Expedition.ID
LEFT JOIN TraeArch ON TraeArch.AbtKdArWID = AbtKdArW.ID
LEFT JOIN TraeArti ON TraeArch.TraeArtiID = TraeArti.ID
LEFT JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
WHERE Wochen.Woche = $1$
  AND Holding.ID IN ($2$)
  AND Bereich.ID IN ($3$)
  AND Produktion.ID IN ($4$)
GROUP BY Expedition.Bez, Produktion.Bez, Holding.Holding, KUnden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Suchcode, Vsa.Bez, Vsa.Name1, Vsa.Name2, Vsa.GebaeudeBez, Abteil.Abteilung, Abteil.Bez, Abteil.RechnungsMemo, Bereich.BereichBez$LAN$, ArtGru.Gruppe, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Wochen.Woche, KdArti.LeasPreis, KdArti.Waschpreis;