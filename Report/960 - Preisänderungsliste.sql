WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KDARTI'
)
SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Standort.Bez AS Haupstandort,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  KdArti.Variante,
  KdArtiStatus.StatusBez AS [Kundenartikel-Status],
  [Bearbeitung vor Anpassung] = (
    SELECT TOP 1 pa.WaschPreis
    FROM PrArchiv pa
    WHERE pa.KdArtiID = PrArchiv.KdArtiID
      AND pa.Aktivierungszeitpunkt < PrArchiv.Aktivierungszeitpunkt
    ORDER BY pa.Aktivierungszeitpunkt DESC
  ),
  [Leasing vor Anpassung] = (
    SELECT TOP 1 pa.LeasPreis
    FROM PrArchiv pa
    WHERE pa.KdArtiID = PrArchiv.KdArtiID
      AND pa.Aktivierungszeitpunkt < PrArchiv.Aktivierungszeitpunkt
    ORDER BY pa.Aktivierungszeitpunkt DESC
  ),
  PrArchiv.Datum AS [Änderung effektiv ab],
  PrArchiv.WaschPreis AS [Bearbeitung nach Anpassung],
  PrArchiv.LeasPreis AS [Leasing nach Anpassung],
  COALESCE(PeKo.Bez, N'') AS Preiserhöhung,
  COALESCE(Mitarbei.Name, N'') AS [PE-Durchführungs-Mitarbeiter],
  KdArti.ID AS KdArtiID
FROM PrArchiv
JOIN KdArti ON PrArchiv.KdArtiID = KdArti.ID
CROSS APPLY advFunc_GetLeasPreisProWo(KdArti.ID) AS KdArtiLeasProWoche
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdArtiStatus ON KdArti.[Status] = KdArtiStatus.[Status]
LEFT OUTER JOIN PeKo ON PrArchiv.PeKoID = PeKo.ID AND PrArchiv.PeKoID > 0
LEFT OUTER JOIN Mitarbei ON PeKo.DurchfuehrungMitarbeiID = Mitarbei.ID
WHERE PrArchiv.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Kunden.KdGfID IN ($3$)
  AND Kunden.FirmaID IN ($2$)
  AND Kunden.ZoneID IN ($4$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);