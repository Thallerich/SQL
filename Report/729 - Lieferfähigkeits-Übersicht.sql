/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Lieferdaten                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH AnfDaten AS (
  SELECT AnfKo.Lieferdatum, AnfPo.Angefordert, AnfPo.Geliefert, AnfPo.KdArtiID, AnfKo.VsaID, Artgroe.Groesse, Artgroe.ID as ArtgroeID
  FROM AnfPo, AnfKo, artgroe
  WHERE AnfPo.AnfKoID = AnfKo.ID
   and artgroe.id = Anfpo.artgroeid
    AND AnfKo.Lieferdatum BETWEEN $1$ AND $2$
    AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
)
,UmlaufDaten AS (SELECT VsaID,  KdArtiID, ArtGroeID, SUM(Umlauf) AS Umlauf
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
SELECT AnfDaten.LieferDatum, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa
,Bereich,Artgru.Gruppe, Artgru.ArtgruBez$LAN$, Prodhier.Lagerkategorie, Prodhier.ProdhierBez$LAN$
,  Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez,
Anfdaten.Groesse, Artikel.Stueckgewicht, Standkonbez$LAN$, SUM(AnfDaten.Angefordert) AS Angefordert, SUM(AnfDaten.Geliefert) AS Geliefert, SUM(AnfDaten.Angefordert - AnfDaten.Geliefert) AS Differenz, ROUND(SUM(AnfDaten.Geliefert) / SUM(IIF(AnfDaten.Angefordert = 0, 1, AnfDaten.Angefordert)) * 100, 2) AS Prozent, Umlaufdaten.Umlauf as Umlauf
/*FROM AnfDaten, VSA, Kunden, KdArti, Artikel, Bereich
WHERE AnfDaten.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND AnfDaten.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Bereich.ID IN ($3$)
  AND (($4$ = 1 AND AnfDaten.Angefordert - AnfDaten.Geliefert <> 0) OR ($4$ = 0))
  AND Kunden.FirmaID IN ($5$)
  AND Kunden.StandortID IN ($6$)
  and Kunden.KdGfID in ($7$) */
FROM AnfDaten
join VSA on AnfDaten.VsaID = Vsa.ID 
join Kunden on Vsa.KundenID = Kunden.ID
join KdArti on AnfDaten.KdArtiID = KdArti.ID
join Artikel on KdArti.ArtikelID = Artikel.ID
join ARTGRU on ARTIKEL.ArtGruID = ARTGRU.ID
join prodhier on ARTIKEL.ProdHierID = PRODHIER.id
join Bereich on Artikel.BereichID = Bereich.ID
join standkon on standkon.id = vsa.standkonid
left join UmlaufDaten on UmlaufDaten.KdArtiID = AnfDaten.KdArtiID and UmlaufDaten.ArtGroeID = AnfDaten.ArtGroeID and AnfDaten.VsaID = UmlaufDaten.VsaID
where Bereich.ID IN ($3$)
  AND (($4$ = 1 AND AnfDaten.Angefordert - AnfDaten.Geliefert <> 0) OR ($4$ = 0))
  AND Kunden.FirmaID IN ($5$)
  AND Kunden.StandortID IN ($6$)
  and Kunden.KdGfID in ($7$)
GROUP BY AnfDaten.LieferDatum, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$,Anfdaten.Groesse, Umlaufdaten.Umlauf, Standkonbez$LAN$
,Bereich,Artgru.Gruppe, Artgru.ArtgruBez$LAN$, Prodhier.Lagerkategorie, Prodhier.ProdhierBez$LAN$,Artikel.Stueckgewicht
ORDER BY Artikel.ArtikelNr, AnfDaten.LieferDatum;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Artikel Gesamtaufstellung                                                                                                 ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH AnfDaten AS (
  SELECT AnfKo.Lieferdatum, AnfPo.Angefordert, AnfPo.Geliefert, AnfPo.KdArtiID, AnfKo.VsaID, Artgroe.Groesse, Artgroe.ID as ArtgroeID
  FROM AnfPo, AnfKo, artgroe
  WHERE AnfPo.AnfKoID = AnfKo.ID
   and artgroe.id = Anfpo.artgroeid
    AND AnfKo.Lieferdatum BETWEEN $1$ AND $2$
    AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0)
)
SELECT  Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, SUM(AnfDaten.Angefordert) AS Angefordert, SUM(AnfDaten.Geliefert) AS Geliefert, SUM(AnfDaten.Angefordert - AnfDaten.Geliefert) AS Differenz
FROM AnfDaten
join VSA on AnfDaten.VsaID = Vsa.ID 
join Kunden on Vsa.KundenID = Kunden.ID
join KdArti on AnfDaten.KdArtiID = KdArti.ID
join Artikel on KdArti.ArtikelID = Artikel.ID
join Bereich on Artikel.BereichID = Bereich.ID
where Bereich.ID IN ($3$)
  AND (($4$ = 1 AND AnfDaten.Angefordert - AnfDaten.Geliefert <> 0) OR ($4$ = 0))
  AND Kunden.FirmaID IN ($5$)
  AND Kunden.StandortID IN ($6$)
  and Kunden.KdGfID in ($7$)
GROUP BY  Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Artikel.ArtikelNr;