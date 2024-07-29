SELECT SUM(LsPo.Menge) AS Menge,
  [Week].Woche AS Kalenderwoche,
  RechPo.Bez AS Positionsbezeichnung,
  Artikel.ArtikelNr,
  KdArti.Variante,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  RechPo.EPreis AS Einzelpreis,
  SUM(LsPo.Menge) * RechPo.EPreis AS Positionssumme,
  Abteil.Abteilung AS Kostenstelle,
  RechPo.Rabatt,
  RechPo.RabattProz AS Rabattsatz
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN [Week] ON LsKo.Datum BETWEEN [Week].VonDat AND [Week].BisDat
JOIN RechPo ON LsPo.RechPoID = RechPo.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
LEFT OUTER JOIN KdArti ON KdArti.ID = RechPo.KdArtiID
LEFT OUTER JOIN Artikel ON Artikel.ID = KdArti.ArtikelID
WHERE RechPo.RechKoID = $RECHKOID$
GROUP BY [Week].Woche,
  RechPo.Bez,
  Artikel.ArtikelNr,
  KdArti.Variante,
  Artikel.ArtikelBez$LAN$,
  RechPo.EPreis,
  Abteil.Abteilung,
  RechPo.Rabatt,
  RechPo.RabattProz;