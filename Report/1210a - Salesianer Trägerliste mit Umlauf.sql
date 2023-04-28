DROP TABLE IF EXISTS #Customer;
DROP TABLE IF EXISTS #ProductionLocation;

CREATE TABLE #Customer (
  ID int PRIMARY KEY
);

CREATE TABLE #ProductionLocation (
  ID int PRIMARY KEY
);

INSERT INTO #Customer (ID)
SELECT Kunden.ID
FROM Kunden
WHERE Kunden.ID IN ($3$);

INSERT INTO #ProductionLocation (ID)
SELECT Standort.ID
FROM Standort
WHERE Standort.ID IN ($4$);

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'EINZHIST')
),
Trägerstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'TRAEGER')
),
EAScans AS (
  SELECT Scans.EinzHistID, MAX(Scans.[DateTime]) AS Scan, Scans.Menge 
  FROM Scans 
  where (SCANS.Menge = 1 or (Scans.Menge = -1 and lspoid > 0))
  GROUP BY Scans.EinzHistID, Scans.Menge
)
SELECT Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Standort.Bez AS Standort,
  Vsa.VsaNr AS [VSA-Nummer],
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.Name1 AS [VSA-Adresszeile 1],
  Vsa.Name2 AS [VSA-Adresszeile 2],
  Vsa.GebaeudeBez AS Gebäudebezeichnung,
  VsaAbteil.Abteilung AS [Kostenstelle VSA],
  VsaAbteil.Bez AS [Kostenstellenbezeichnung VSA],
  Schrank.SchrankNr,
  TraeFach.Fach,
  Traeger.Traeger AS [Träger-Nummer],
  Traeger.Nachname,
  Traeger.Vorname,
  Traeger.PersNr AS Personalnummer,
  TraegerAbteil.Abteilung AS [Kostenstelle Träger],
  TraegerAbteil.Bez AS [Kostenstellenbezeichnung Träger],
  Trägerstatus.StatusBez AS [Status Träger],
  Bereich.Bereich AS Produktbereich,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  KdArti.Variante,
  KdArti.VariantBez AS Variantenbezeichnung,
  TraeArti.Menge AS [Max. Bestand],
  Umlauf = (
    SELECT COUNT(T.ID)
    FROM EinzHist AS T
    WHERE T.TraeArtiID = EinzHist.TraeArtiID
      AND T.Status BETWEEN N'Q' AND N'W'
      AND T.Einzug IS NULL
      AND T.IsCurrEinzHist = 1
  ),
  Kostenlos = (
    SELECT COUNT(T.ID)
    FROM EinzHist AS T
    WHERE T.TraeArtiID = EinzHist.TraeArtiID
      AND T.Status BETWEEN N'Q' AND N'W'
      AND T.Einzug IS NULL
      AND T.Kostenlos = 1
      AND T.IsCurrEinzHist = 1
  ),
  EinzHist.Barcode,
  CAST(IIF(EinzHist.Status > N'Q', 1, 0) AS bit) AS Stilllegung,
  Teilestatus.StatusBez AS Teilestatus,
  EScans.Scan AS [Scanzeitpunkt letzter Eingang],
  AScans.Scan AS [Scanzeitpunkt letzter Ausgang],
  EinzHist.Eingang1 AS [Datum letzter Eingang],
  EinzHist.Ausgang1 AS [Datum letzter Ausgang],
  EinzHist.IndienstDat AS [Letztes Einsatzdatum],
  Lagerart.Zustand as Qualität,
  EinzTeil.RuecklaufG AS [Waschzyklen gesamt],
  EinzHist.RuecklaufK AS [Waschzyklen aktueller Kunde],
  CAST(ROUND(EinzTeil.AlterInfo / 4.33, 0) AS int) as [Alter in Monaten],
  Actions.ActionsBez$LAN$ AS [letzte Aktion],
  ZielNr.ZielNrBez$LAN$ AS [letzter Ort]
FROM EinzHist
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN TraeArti ON EinzHist.TraeArtiID = TraeArti.ID
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Abteil AS VsaAbteil ON Vsa.AbteilID = VsaAbteil.ID
JOIN Abteil AS TraegerAbteil ON Traeger.AbteilID = TraegerAbteil.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
JOIN Actions ON EinzTeil.LastActionsID = Actions.ID
JOIN ZielNr ON EinzTeil.ZielNrID = ZielNr.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
LEFT JOIN TraeFach ON TraeFach.TraegerID = Traeger.ID
LEFT JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
JOIN Teilestatus ON EinzHist.Status = Teilestatus.Status
JOIN Trägerstatus ON Traeger.Status = Trägerstatus.Status
JOIN Lagerart ON EinzHist.LagerartID = Lagerart.ID
LEFT JOIN EAScans EScans ON EScans.EinzHistID = EinzHist.ID AND Escans.Menge = 1
LEFT JOIN EAScans AScans ON AScans.EinzHistID = EinzHist.ID AND Ascans.Menge = -1
WHERE Kunden.ID IN (SELECT ID FROM #Customer)
  AND StandBer.ProduktionID IN (SELECT ID FROM #ProductionLocation)
  AND EinzHist.Status BETWEEN N'Q' AND N'W'
  AND EinzHist.Einzug IS NULL
  AND EinzHist.IsCurrEinzHist = 1
  AND EinzHist.EinzHistTyp = 1
  AND EinzHist.PoolFkt = 0
ORDER BY KdNr, [VSA-Nummer], [Träger-Nummer], ArtikelNr, Groesse;