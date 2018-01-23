/* Wunsch:
SGF | Barcode | ArtikelNr | Artikelbezeichnung | Größe | Datum Anlage | Datum Aktivierung | Datum Entnahme | Datum gepatcht | Durchlaufzeit in Tagen
Eventuell Bestell- und Wareneingangsdatum wenn möglich
Datumsfilter auf Anlage, Filter auf Lagerstandort
Inkl. Teile die noch nicht aktiviert wurden
*/

-- STHA: Entnahmedatum, Bestelldatum, Wareneingangsdatum nicht möglich, da nicht gespeichert / nicht dem Einzelteil zuordenbar

DECLARE @von TIMESTAMP;
DECLARE @bis TIMESTAMP;

@von = CONVERT($1$ + ' 00:00:00', SQL_TIMESTAMP);
@bis = CONVERT($2$ + ' 23:59:59', SQL_TIMESTAMP);

SELECT KdGf.KurzBez AS SGF, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, CONVERT(Teile.Anlage_, SQL_DATE) AS Anlage, Teile.Entnommen, Teile.PatchDatum AS Patchdatum, Teile.IndienstDat AS Aktivierung, Teile.IndienstDat - CONVERT(Teile.Anlage_, SQL_DATE) AS Durchlaufzeit
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