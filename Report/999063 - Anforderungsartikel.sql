DECLARE @Liefermenge TABLE (
  KdArtiID int,
  ArtGroeID int,
  VsaID int,
  Liefermenge numeric(18,4)
);

INSERT INTO @Liefermenge (KdArtiID, ArtGroeID, VsaID, Liefermenge)
SELECT LsPo.KdArtiID, LsPo.ArtGroeID, LsKo.VsaID, SUM(LsPo.Menge)
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
WHERE Vsa.KundenID IN ($6$)
  AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
GROUP BY LsPo.KdArtiID, LsPo.ArtGroeID, LsKo.VsaID;

SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Standort.Bez AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], KdArti.ID AS KdArtiID, Bereich.BereichBez$LAN$ AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, VsaAnf.MitInventur AS [mit Inventur], VsaAnf.Bestand AS Vertragsbestand, VsaAnf.BestandIst AS [Ist-Bestand], VsaAnf.Durchschnitt AS [durchschnittliche Liefermenge], Liefermenge.Liefermenge AS [Liefermenge im Zeitraum]
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN @Liefermenge AS Liefermenge ON VsaAnf.KdArtiID = Liefermenge.KdArtiID AND VsaAnf.ArtGroeID = Liefermenge.ArtGroeID AND VsaAnf.VsaID = Liefermenge.VsaID
WHERE Kunden.ID IN ($6$)
  AND Bereich.ID IN ($7$)
  AND VsaAnf.Status < N'E'
  AND Vsa.[Status] = N'A';