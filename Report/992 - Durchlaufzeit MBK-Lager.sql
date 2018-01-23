/* Wunsch:
SGF | Barcode | ArtikelNr | Artikelbezeichnung | Größe | Datum Anlage | Datum Aktivierung | Datum Entnahme | Datum gepatcht | Durchlaufzeit in Tagen
Eventuell Bestell- und Wareneingangsdatum wenn möglich
Datumsfilter auf Anlage, Filter auf Lagerstandort
Inkl. Teile die noch nicht aktiviert wurden
*/

-- STHA: Entnahmedatum, Bestelldatum, Wareneingangsdatum nicht möglich, da nicht gespeichert / nicht dem Einzelteil zuordenbar
-- STHA: IndienstDatum -> spezielle Kritieren, siehe Tabellendefinitionen

DECLARE @von datetime;
DECLARE @bis datetime;

SET @von = $1$;
SET @bis = DATEADD(day, 1, $2$);

SELECT KdGf.KurzBez AS SGF, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, CONVERT(date, Teile.Anlage_) AS Anlage, Teile.Entnommen, Teile.PatchDatum, Teile.IndienstDat AS Aktivierung, DATEDIFF(day, Teile.IndienstDat, CONVERT(date, Teile.Anlage_)) AS Durchlaufzeit
FROM Teile, Vsa, Kunden, KdGf, Artikel, ArtGroe, LagerArt
WHERE Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND Teile.LagerArtID = LagerArt.ID
  AND Teile.Status <> '5' --keine stornierten Teile
  AND LagerArt.LagerID = $3$ --Lagerstandort
  AND Teile.Anlage_ BETWEEN @von AND @bis;