USE [Salesianer_Archive]
GO

CREATE OR ALTER VIEW [sapbw].[V_BW_LIEFERQUOTE] AS
  with LS as (select lk.ID as LsKoID, Lk.LsNr, lk.Datum as LSDatum, lp.KdArtiID,lp.ArtGroeID, Sum(lp.menge) Menge
  from salesianer.dbo.lsko lk join salesianer.dbo.lspo lp on lp.lskoid = lk.ID
  where lk.Datum >= '2019-01-01'
  group by lk.ID , Lk.LsNr, lk.Datum, lp.KdArtiID,lp.ArtGroeID)
  ,OWSLS as (select lk.ID as LsKoID, Lk.LsNr, lk.Datum as LSDatum, lp.KdArtiID,lp.ArtGroeID, Sum(lp.menge) Menge
  from ows.dbo.lsko lk join ows.dbo.lspo lp on lp.lskoid = lk.ID
  where lk.Datum >= '2019-01-01'
  group by lk.ID , Lk.LsNr, lk.Datum, lp.KdArtiID,lp.ArtGroeID)
  /*select *
  , isnull(q.LSDatum, q.AnfDatum) as Datum
  , isnull(q.LSMenge,0) - isnull(q.Angefordert,0) as Abweichung
  , case 
    when isnull(q.LSMenge,0) - isnull(q.Angefordert,0) > 0 and q.Angefordert =0 then 'EA' 
    when isnull(q.LSMenge,0) - isnull(q.Angefordert,0) = 0 then '='
    when isnull(q.LSMenge,0) - isnull(q.Angefordert,0) > 0 then 'ÜB' 
    else 'FT' end as Art
  , iif(q.Angefordert =0, 'N', 'J') as WurdeAngefordert
  , iif(isnull(q.LSMenge,0) - isnull(q.Angefordert,0) <0, '< 0', iif(isnull(q.LSMenge,0) - isnull(q.Angefordert,0) >0, '> 0','0')) as HatAbweichung
  from (*/
  select --ak.ID as AnfKoId
    --, ak.VsaID 
    --, 
      vs.VsaNr
    , ku.KdNr
    --, ak.LsKoId
    , ak.Status
    , ak.Lieferdatum as AnfDatum
    , ak.AuftragsNr
    /*, ap.ID as AnfPoID
    , ap.KdArtiID
    , sum(ap.Angefordert) as Angefordert_Orig
    , ap.Geliefert
    , ap.BestaetZeitpunkt*/
    , sum(case when datediff(mi,ap.Anlage_,ap.BestaetZeitpunkt) < 1 then 0 else ap.Angefordert end) as Angefordert
    --, ap.Anlage_
    --, ap.ArtGroeID
    --, ls.ArtGroeID as lsartgroeid
    ,ArtikelNr = UPPER(ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse))
    , ar.ArtikelNr as Artikelbasis
    , ArtGroe.Groesse
    , case when ME.IsoCode = '-' then 'ST' else ME.Isocode end  as Mengeneinheit  
    --, ka.kdberid
    , be.Bereich
    --, ka.ErsatzFuerKdArtiID
    , ls.lsnr
    , ls.LSDatum
    , Sum(isnull(ls.Menge, 0)) as LSMenge
    --, Sum(isnull(ls.Menge, 0)) - sum(case when datediff(mi,ap.Anlage_,ap.BestaetZeitpunkt) < 1 then 0 else ap.Angefordert end) as Abweichung
  from salesianer.dbo.anfko ak 
  join salesianer.dbo.anfpo ap on ap.AnfKoID = ak.id and Angefordert >0 and Geliefert >0 
  join salesianer.dbo.ARTGROE on artgroe.id = ap.ArtGroeID
  join salesianer.dbo.vsa vs on vs.id = ak.VsaID
  join salesianer.dbo.kunden ku on ku.id = vs.KundenID
  join salesianer.dbo.kdarti ka on ka.id = ap.KdArtiID
  join salesianer.dbo.artikel ar on ar.id = ka.ArtikelID -- and ar.prodhierid <> 68--Artikelnr in ('111260022001','111260020001')
  join salesianer.dbo.me on me.id = ar.meid
  join salesianer.dbo.KDBER kb on kb.id = ka.KdBerID
  join salesianer.dbo.BEREICH be on be.id = kb.BereichID
  left join ls on ls.lskoid = ak.LsKoID and ls.KdArtiID = ap.KdArtiID and (ap.ArtGroeID = ls.ArtGroeID or ap.ArtGroeID = -1)
  where ak.Lieferdatum >= '2019-01-01'  and (ak.Update_ >= dateadd(day, -10,getdate()) or ap.Update_ >= dateadd(day, -10,getdate()))
  and ak.Status >= 'I'
  group by --ak.ID
    --, 
      vs.VsaNr
    , ku.KdNr
    , ak.LsKoId
    , ak.Status
    , ak.Lieferdatum
    , ak.AuftragsNr
    --, ap.KdArtiID
    , ar.artikelNr
    , artgroe.Groesse
    , me.IsoCode
    , be.Bereich
    --, ka.ErsatzFuerKdArtiID
    , ls.lsnr
    , ls.LSDatum
    --, ls.Menge
    -- ,ls.artgroeid, ap.ArtGroeID
  union 
  select --ak.ID as AnfKoId
    --, ak.VsaID 
    --, 
      vs.VsaNr
    , ku.KdNr
    --, ak.LsKoId
    , ak.Status
    , ak.Lieferdatum as AnfDatum
    , ak.AuftragsNr
    --, ap.ID as AnfPoID
    --, ap.KdArtiID
    --, sum(ap.Angefordert) as Angefordert_Orig
    --, ap.Geliefert
    --, ap.BestaetZeitpunkt
    , sum(case when datediff(mi,ap.Anlage_,ap.BestaetZeitpunkt) < 1 then 0 else ap.Angefordert end) as Angefordert
    --, ap.Anlage_
    --, ap.ArtGroeID
    --, ls.ArtGroeID as lsartgroeid
    ,ArtikelNr = UPPER(ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse))
    , ar.ArtikelNr as ArtikelBasis
    , ArtGroe.Groesse
    , case when ME.IsoCode = '-' then 'ST' else ME.Isocode end  as Mengeneinheit  
    --, ka.kdberid
    , be.Bereich
    --, ka.ErsatzFuerKdArtiID
    , owsls.lsnr
    , owsls.LSDatum
    , Sum(isnull(owsls.Menge, 0)) as LSMenge
    --, Sum(isnull(ls.Menge, 0)) - sum(case when datediff(mi,ap.Anlage_,ap.BestaetZeitpunkt) < 1 then 0 else ap.Angefordert end) as Abweichung
  from OWS.dbo.anfko ak 
  join ows.dbo.anfpo ap on ap.AnfKoID = ak.id and Angefordert >0 and Geliefert >0
  join ows.dbo.ARTGROE on artgroe.id = ap.ArtGroeID
  join ows.dbo.vsa vs on vs.id = ak.VsaID
  join ows.dbo.kunden ku on ku.id = vs.KundenID
  join ows.dbo.kdarti ka on ka.id = ap.KdArtiID
  join ows.dbo.artikel ar on ar.id = ka.ArtikelID -- and ar.prodhierid <> 68--Artikelnr in ('111260022001','111260020001')
  join ows.dbo.me on me.id = ar.meid
  join ows.dbo.KDBER kb on kb.id = ka.KdBerID
  join ows.dbo.BEREICH be on be.id = kb.BereichID
  left join owsls on owsls.lskoid = ak.LsKoID and owsls.KdArtiID = ap.KdArtiID and (ap.ArtGroeID = owsls.ArtGroeID or ap.ArtGroeID = -1)
  where ak.Lieferdatum >= '2019-01-01'   and (ak.Update_ >= dateadd(day, -10,getdate()) or ap.Update_ >= dateadd(day, -10,getdate()))
  and ak.Status >= 'I'
  group by --ak.ID
    --, 
      vs.VsaNr
    , ku.KdNr
    , ak.LsKoId
    , ak.Status
    , ak.Lieferdatum
    , ak.AuftragsNr
    --, ap.KdArtiID
    , ar.artikelNr
    , artgroe.Groesse
    , me.IsoCode
    , be.Bereich
    --, ka.ErsatzFuerKdArtiID
    , owsls.lsnr
    , owsls.LSDatum
    --, ls.Menge
    -- ,ls.artgroeid, ap.ArtGroeID
  --) q 

GO