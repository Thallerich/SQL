-- Korrigiert Ist-Bestände bei den VSA-Anforderungsartikeln über OP-Teile mit Status "beim Kunden" und letzter Lieferung an eine VSA des angegeben Kunden.

DECLARE @KdNr Integer;

@KdNr = 15200; --Kunde bei dem Istbestände korrigiert werden sollen.

TRY
  DROP TABLE #TmpAnfBest;
  DROP TABLE #TmpOPTeile;
CATCH ALL END;

-- Sichern der aktuellen VsaAnf-Tabelle (Vertragsbestand / Istbestand)
SELECT VsaAnf.*
INTO __VsaAnf20131218
FROM VsaAnf;

-- Auswerten / Ändern Vertrags-/Istbestand pro anforderbarem Artikel
SELECT OPTeile.VsaID, OPTeile.ArtikelID, SUM(IIF(OPTeile.Status = 'R', 1, 0)) AS OPTeileIst, COUNT(OPTeile.ID) AS OPTeile
INTO #TmpOPTeile
FROM OPTeile
WHERE OPTeile.Status BETWEEN 'C' AND 'R'
GROUP BY OPTeile.VsaID, OPTeile.ArtikelID;

SELECT VsaAnf.ID AS VsaAnfID, Kunden.KdNr, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaAnf.Bestand, OPTeile.OPTeile, VsaAnf.BestandIst, OPTeile.OPTeileIst
INTO #TmpAnfBest
FROM VsaAnf, Vsa, Kunden, KdArti, ViewArtikel Artikel, #TmpOPTeile OPTeile
WHERE VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.LanguageID = $LANGUAGE$
  AND OPTeile.VsaID = Vsa.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Kunden.KdNr = @KdNr
ORDER BY Kunden.KdNr, VsaNr, Artikel.ArtikelNr;

UPDATE VsaAnf SET VsaAnf.BestandIst = AnfBest.OPTeileIst, VsaAnf.Bestand = AnfBest.OPTeile
FROM VsaAnf, #TmpAnfBest AnfBest
WHERE VsaAnf.ID = AnfBest.VsaAnfID;