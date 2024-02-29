USE [Salesianer_Archive]
GO

CREATE OR ALTER   view [sapbw].[V_BW_ArtikelSGF] as
WITH Umlauf AS (
    SELECT _Umlauf.Datum, _Umlauf.KdArtiID,_Umlauf.ArtGroeID, vsa.KundenID, SUM(_Umlauf.Umlauf) AS Umlauf
    FROM Salesianer.dbo._Umlauf
	join Salesianer.dbo.vsa on vsa.id = _umlauf.VsaID
    GROUP BY _Umlauf.Datum,_Umlauf.KdArtiID, _Umlauf.ArtGroeID, KundenID)
, OWSUmlauf AS (
	SELECT _Umlauf.Datum, _Umlauf.KdArtiID,_Umlauf.ArtGroeID, vsa.KundenID, SUM(_Umlauf.Umlauf) AS Umlauf
    FROM ows.dbo._Umlauf
	join ows.dbo.vsa on vsa.id = _umlauf.VsaID
    GROUP BY _Umlauf.Datum,_Umlauf.KdArtiID, _Umlauf.ArtGroeID, KundenID)
select Artikel, Kurzbez, SUm(AnzKunden) as AnzKunden, sum (AnzVertragskunden) as AnzVertragskunden, Sum(Umlauf) as Umlauf from (
select 'ADV' as syst, UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)) AS Artikel
	, kdgf.KurzBez
	, count(distinct case when Kunden.status = 'A' and kdarti.status = 'A' then kdarti.Kundenid end ) as AnzKunden
	, count(distinct case when Vertragsartikel=1 and Kunden.status = 'A' and kdarti.status = 'A' then kdarti.kundenid end ) as AnzVertragskunden
	, SUm(Umlauf.Umlauf	) as Umlauf
from Salesianer.dbo.kdarti
join Salesianer.dbo.Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Salesianer.dbo.ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
join Salesianer.dbo.kunden on kunden.id = kdarti.KundenID
join Salesianer.dbo.kdgf on kdgf.id = kunden.kdgfid
join Umlauf on ArtGroeID = Artgroe.ID and Umlauf.KdArtiID = Kdarti.id and Datum >= getdate()-7 and umlauf.kundenid = Kunden.ID
where kdnr <> 15200 and Artikel.id >0
group by UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)), kdgf.KurzBez
union
select 'OWS' as syst,UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)) AS Artikel
	, kdgf.KurzBez
	, count(distinct case when Kunden.status = 'A' and kdarti.status = 'A' then kdarti.Kundenid end ) as AnzKunden
	, count( distinct case when Vertragsartikel=1 and Kunden.status = 'A' and kdarti.status = 'A' then kdarti.Kundenid end) as AnzVertragskunden
	, SUm(OWSUmlauf.Umlauf	) as Umlauf
from OWS.dbo.kdarti
join OWS.dbo.Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN OWS.dbo.ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
join OWS.dbo.kunden on kunden.id = kdarti.KundenID
join OWS.dbo.kdgf on kdgf.id = kunden.kdgfid
join OWSUmlauf on ArtGroeID = Artgroe.ID and OWSUmlauf.KdArtiID = Kdarti.id and Datum >= getdate()-7 and OWSumlauf.kundenid = Kunden.ID
group by UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)), kdgf.KurzBez
) temp group by Artikel, Kurzbez
GO

