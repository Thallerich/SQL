/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Lieferdaten                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH AnfDaten AS (
  SELECT AnfKo.Lieferdatum, IIF((VsaBer.AnfAusEpo > 1 OR KdBer.AnfAusEPo > 1 OR Kunden.CheckPackmenge = 1) AND AnfPo.Angefordert % COALESCE(NULLIF(ArtiStan.PackMenge, -1), Artikel.PackMenge) != 0 AND AnfPo.Angefordert = 1, 0, AnfPo.Angefordert) AS Angefordert, AnfPo.Geliefert, AnfPo.KdArtiID, AnfKo.VsaID, ArtGroe.Groesse, ArtGroe.ID AS ArtGroeID
  FROM AnfPo
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID
  JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
  JOIN VsaBer ON AnfKo.VsaID = VsaBer.VsaID AND KdArti.KdBerID = VsaBer.KdBerID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN Kunden ON KdBer.KundenID = Kunden.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  LEFT JOIN ArtiStan ON ArtiStan.ArtikelID = Artikel.ID AND AnfKo.ProduktionID = ArtiStan.StandortID
  WHERE AnfKo.Lieferdatum BETWEEN $STARTDATE$ AND $ENDDATE$
    AND (IIF((VsaBer.AnfAusEpo > 1 OR KdBer.AnfAusEPo > 1 OR Kunden.CheckPackmenge = 1) AND AnfPo.Angefordert % COALESCE(NULLIF(ArtiStan.PackMenge, -1), Artikel.PackMenge) != 0 AND AnfPo.Angefordert = 1, 0, AnfPo.Angefordert) > 0 OR AnfPo.Geliefert > 0)
),
UmlaufDaten AS (
  SELECT VsaID,  KdArtiID, ArtGroeID, SUM(Umlauf) AS Umlauf
  FROM (
    SELECT VsaLeas.VsaID,  VsaLeas.KdArtiID, - 1 AS ArtGroeID, SUM(Menge) Umlauf
    FROM VsaLeas
    INNER JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
    WHERE Coalesce(VsaLeas.Ausdienst, '2099/52') > (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat)
    GROUP BY VsaLeas.VSaID, VsaLeas.KdArtiID  
    UNION ALL
    SELECT VsaAnf.VsaID,  VsaAnf.KdArtiID, VsaAnf.ArtGroeID, SUM(Bestand) Umlauf
    FROM VsaAnf
    WHERE VsaAnf.Bestand <> 0
    GROUP BY VsaAnf.VsaID, VsaAnf.KdArtiID, VsaAnf.ArtGroeID
    UNION ALL
    SELECT Strumpf.VsaID,  Strumpf.KdArtiID, - 1 AS ArtGroeID, COUNT(Strumpf.ID) Umlauf
    FROM Strumpf
    WHERE Strumpf.Status <> 'X'
    GROUP BY Strumpf.VsaID, Strumpf.KdArtiID 
    UNION ALL
    SELECT Daten1.VsaID, Daten1.KdArtiID, Daten1.ArtGroeID, IIF(Daten1.Umlauf > Daten2.Aufkauf, Daten1.Umlauf, Daten2.Aufkauf) Umlauf
    FROM (
      SELECT EinzHist.VsaID, EinzHist.KdArtiID, EinzHist.ArtGroeID, COUNT(EinzHist.ID) AS Umlauf
      FROM EinzHist, EinzTeil, Traeger
      WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
        AND EinzHist.STATUS BETWEEN 'A' AND 'Q'
        AND Traeger.ID = EinzHist.TraegerID
        AND Traeger.STATUS <> 'I'
      GROUP BY EinzHist.VsaID, EinzHist.KdArtiID, EinzHist.ArtGroeID
    ) Daten1, (
      SELECT TraeArti.VsaID, TraeArti.KdArtiID, TraeArti.ArtGroeID, SUM(TraeArti.MengeAufkauf) AS Aufkauf
      FROM TraeArti, Traeger
      WHERE TraeArti.VsaID > - 1
        AND TraeArti.TraegerID = Traeger.ID
        AND Traeger.STATUS <> 'I'
      GROUP BY TraeArti.VsaID, TraeArti.KdArtiID, TraeArti.ArtGroeID
    ) Daten2
    WHERE Daten1.VsaID = Daten2.VsaID
      AND Daten1.KdArtiID = Daten2.KdArtiID
      AND Daten1.ArtGroeID = Daten2.ArtGroeID
    UNION ALL
    SELECT Traeger.VsaID, KdArAppl.KdArtiID, -1 AS ArtGroeID, COUNT(KdArAppl.ApplKdArtiID) Umlauf
    FROM EinzHist, EinzTeil, Traeger, KdArAppl
    WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
      AND EinzHist.STATUS BETWEEN 'A' AND 'Q'
      AND EinzHist.KdArtiID = KdArAppl.KdArtiID
      AND KdArAppl.ArtiTypeID = 3
      AND EinzHist.TraegerID = Traeger.ID
      AND Traeger.STATUS <> 'I'
    GROUP BY Traeger.VsaID, KdArAppl.KdArtiID
    UNION ALL  
    SELECT Traeger.VsaID,  KdArAppl.KdArtiID, -1 AS ArtGroeID, COUNT(KdArAppl.ApplKdArtiID) Umlauf
    FROM EinzHist, EinzTeil, Traeger, KdArAppl
    WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
      AND EinzHist.STATUS BETWEEN 'A' AND 'Q'
      AND EinzHist.KdArtiID = KdArAppl.KdArtiID
      AND EinzHist.TraegerID = Traeger.ID
      AND Traeger.STATUS <> 'I'
      AND KdArAppl.ArtiTypeID = 2
      AND (
        (KdArAppl.NutzeZeile1 = 1 AND Traeger.Namenschild1 IS NOT NULL)
        OR (KdArAppl.NutzeZeile2 = 1 AND Traeger.Namenschild2 IS NOT NULL)
        OR (KdArAppl.NutzeZeile3 = 1 AND Traeger.Namenschild3 IS NOT NULL)
        OR (KdArAppl.NutzeZeile4 = 1 AND Traeger.Namenschild4 IS NOT NULL)
      )
    GROUP BY Traeger.VsaID, KdArAppl.KdArtiID
  ) AS x
  GROUP BY VsaID, KdArtiID, ArtGroeID
)
SELECT AnfDaten.LieferDatum, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Bereich.Bereich AS Produktbereich, ArtGru.Gruppe AS Artikelgruppe, ArtGru.ArtgruBez$LAN$ AS Artikelgruppenbezeichnung, ProdHier.Lagerkategorie, ProdHier.ProdHierBez$LAN$ AS Produkthierarchie, KdArti.ID AS KdArtiID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, AnfDaten.Groesse AS Größe, Artikel.Stueckgewicht AS Stückgewicht, StandKon.StandKonBez$LAN$ AS Standortkonfiguration, SUM(AnfDaten.Angefordert) AS Angefordert, SUM(AnfDaten.Geliefert) AS Geliefert, SUM(AnfDaten.Angefordert - AnfDaten.Geliefert) AS Differenz, ROUND(SUM(AnfDaten.Geliefert) / SUM(IIF(AnfDaten.Angefordert = 0, 1, AnfDaten.Angefordert)) * 100, 2) AS Prozent, Umlaufdaten.Umlauf AS Umlauf
FROM AnfDaten
JOIN Vsa ON AnfDaten.VsaID = Vsa.ID 
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfDaten.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
JOIN ProdHier ON Artikel.ProdHierID = ProdHier.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
LEFT JOIN UmlaufDaten ON UmlaufDaten.KdArtiID = AnfDaten.KdArtiID AND UmlaufDaten.ArtGroeID = AnfDaten.ArtGroeID AND AnfDaten.VsaID = UmlaufDaten.VsaID
WHERE Bereich.ID IN ($3$)
  AND (($4$ = 1 AND AnfDaten.Angefordert - AnfDaten.Geliefert <> 0) OR ($4$ = 0))
  AND Kunden.FirmaID IN ($5$)
  AND Kunden.StandortID IN ($6$)
  AND Kunden.KdGfID in ($7$)
GROUP BY AnfDaten.LieferDatum, Kunden.KdNr, Kunden.SuchCode, Vsa.ID, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez, Bereich.Bereich, ArtGru.Gruppe, ArtGru.ArtGruBez$LAN$, ProdHier.Lagerkategorie, ProdHier.ProdHierBez$LAN$, KdArti.ID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, AnfDaten.Groesse, Artikel.Stueckgewicht, StandKon.StandKonBez$LAN$, Umlaufdaten.Umlauf
ORDER BY Artikel.ArtikelNr, AnfDaten.LieferDatum;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Artikel Gesamtaufstellung                                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH AnfDaten AS (
  SELECT AnfKo.Lieferdatum, IIF((VsaBer.AnfAusEpo > 1 OR KdBer.AnfAusEPo > 1 OR Kunden.CheckPackmenge = 1) AND AnfPo.Angefordert % COALESCE(NULLIF(ArtiStan.PackMenge, -1), Artikel.PackMenge) != 0 AND AnfPo.Angefordert = 1, 0, AnfPo.Angefordert) AS Angefordert, AnfPo.Geliefert, AnfPo.KdArtiID, AnfKo.VsaID, ArtGroe.Groesse, ArtGroe.ID AS ArtGroeID
  FROM AnfPo
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID
  JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
  JOIN VsaBer ON AnfKo.VsaID = VsaBer.VsaID AND KdArti.KdBerID = VsaBer.KdBerID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN Kunden ON KdBer.KundenID = Kunden.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  LEFT JOIN ArtiStan ON ArtiStan.ArtikelID = Artikel.ID AND AnfKo.ProduktionID = ArtiStan.StandortID
  WHERE AnfKo.Lieferdatum BETWEEN $STARTDATE$ AND $ENDDATE$
    AND (IIF((VsaBer.AnfAusEpo > 1 OR KdBer.AnfAusEPo > 1 OR Kunden.CheckPackmenge = 1) AND AnfPo.Angefordert % COALESCE(NULLIF(ArtiStan.PackMenge, -1), Artikel.PackMenge) != 0 AND AnfPo.Angefordert = 1, 0, AnfPo.Angefordert) > 0 OR AnfPo.Geliefert > 0)
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(AnfDaten.Angefordert) AS Angefordert, SUM(AnfDaten.Geliefert) AS Geliefert, SUM(AnfDaten.Angefordert - AnfDaten.Geliefert) AS Differenz
FROM AnfDaten
JOIN Vsa ON AnfDaten.VsaID = Vsa.ID 
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfDaten.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
WHERE Bereich.ID IN ($3$)
  AND (($4$ = 1 AND AnfDaten.Angefordert - AnfDaten.Geliefert <> 0) OR ($4$ = 0))
  AND Kunden.FirmaID IN ($5$)
  AND Kunden.StandortID IN ($6$)
  AND Kunden.KdGfID in ($7$)
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Artikel.ArtikelNr;