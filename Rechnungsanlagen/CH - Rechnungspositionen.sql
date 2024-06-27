SELECT RechPo.Menge,
  RechPo.Bez AS Positionsbezeichnung,
  Artikel.ArtikelNr,
  KdArti.Variante,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  RechPo.EPreis AS Einzelpreis,
  RechPo.GPreis AS Positionssumme,
  Abteil.Abteilung AS Kostenstelle,
  RechPo.Rabatt,
  RechPo.RabattProz AS Rabattsatz
FROM RechPo
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
LEFT OUTER JOIN KdArti ON KdArti.ID = RechPo.KdArtiID
LEFT OUTER JOIN Artikel ON Artikel.ID = KdArti.ArtikelID
WHERE RechPo.RechKoID = $RECHKOID$;