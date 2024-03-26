CREATE OR ALTER VIEW [sapbw].[UMLAUF_ALL_ONLY_ZERO_DayPlus7]
AS
-- Umlauf DATUM = select CAST(DATEDIFF(DAY,1,GETDATE()-DATEDIFF(DAY,0,GETDATE())%7) AS DATETIME) -->> Letzte Sontag
WITH U AS (
	SELECT _U.Datum,
		K.KdNr,
		V.VsaNr,
		_U.KdArtiID,
		UPPER(A.ArtikelNr+IIF(ISNULL(REPLACE(AG.Groesse,'"',''),'-')='-','','-'+REPLACE(AG.Groesse,'-','/'))) AS Artikel,
		0 Umlauf,
		M.IsoCode ME,
		VW.ID VW_ID,
		FW.ID FW_ID,
		VW.IsoCode VW_IsoCode,
		FW.IsoCode FW_IsoCode
	FROM Salesianer.dbo._Umlauf _U
	JOIN Salesianer.dbo.VSA V ON V.ID=_U.VsaID
	JOIN Salesianer.dbo.ARTIKEL A ON A.ID=_U.ArtikelID
	JOIN Salesianer.dbo.ME M ON A.MEID=M.ID
	JOIN Salesianer.dbo.Kunden K ON V.KundenID=K.ID
	JOIN Salesianer.dbo.Firma F ON K.FirmaID=F.ID
	JOIN Salesianer.dbo.Wae VW ON K.VertragWaeID=VW.ID
	JOIN Salesianer.dbo.Wae FW ON F.WaeID=FW.ID
	LEFT JOIN Salesianer.dbo.ARTGROE AG ON AG.ID=_U.ArtGroeID
	WHERE A.ArtiTypeID=1 -->> Textile Artikel
		AND K.AdrArtID=1 -->> nur Kunde
	GROUP BY _U.Datum,K.KdNr,V.VsaNr,_U.KdArtiID,A.ArtikelNr,M.IsoCode,AG.Groesse,VW.ID,FW.ID,VW.IsoCode,FW.IsoCode
),
VB AS (
	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) Pos,value VarBez
	FROM STRING_SPLIT(N'GEF-A,GEF-H,GEF-1,GEF-3,GEF-4,HANG,UNGEF,1W,2W,3W,4W,12W,24W,8W,99W,6W,26W,16W,32W,52W,SPEZWN,SPL-A,SPL-H,CHEM,FOLIE,GYN,MTLKA,QUER,OBEN,ET,RUDI,LAENGS,AUVA,KORNB,KE,KE-HA,KE-H,EXPR,VE/100,-',',')
),
KA AS (
	SELECT ID,KundenId,KdBerID,VkPreis,WaschPreis,BasisRestwert,GesamtRestwert, STRING_AGG(VB.VarBez,',') WITHIN GROUP (ORDER BY VB.Pos ASC) VarBez, LeasPreis.LeasPreisProWo AS Leasingpreis_VTW, CAST(IIF(KDA.LeasPreisPrListKdArtiID > 0 OR KDA.WaschPreisPrListKdArtiID > 0, 1, 0) AS bit) AS Preisliste
	FROM Salesianer.dbo.KDARTI KDA
  CROSS APPLY Salesianer.dbo.advFunc_GetLeasPreisProWo(KDA.ID) AS LeasPreis
	LEFT JOIN VB ON KDA.VariantBez LIKE '%('+VB.VarBez+')%'
	GROUP BY ID,KundenId,KdBerID,VariantBez,VkPreis,WaschPreis,BasisRestwert,GesamtRestwert, CAST(IIF(KDA.LeasPreisPrListKdArtiID > 0 OR KDA.WaschPreisPrListKdArtiID > 0, 1, 0) AS bit)
)
SELECT DATEADD(DAY,7,MAX(U.Datum)) Datum,
	U.KdNr,
	U.VsaNr,
	U.Artikel,
	KA.VarBez Variante,
	KA.Preisliste,
	0 Umlauf,
	IIF(U.ME='-','ST',U.ME) ME,
	U.VW_IsoCode Vertragswährung,
	U.FW_IsoCode Firmenwährung,
	KA.VkPreis VKPreis_VTW,
	KA.WaschPreis Waschpreis_VTW,
	KA.Leasingpreis_VTW,
	KA.BasisRestwert Basisrestwert_VTW,
	KA.GesamtRestwert Gesamtrestwert_VTW,
	0 VKPreis_HRW,
	0 Waschpreis_HRW,
	0 Leasingpreis_HRW,
	0 Basisrestwert_HRW,
	0 Gesamtrestwert_HRW,
	0 VKPreis_EUR,
	0 Waschpreis_EUR,
	0 Leasingpreis_EUR,
	0 Basisrestwert_EUR,
	0 Gesamtrestwert_EUR
FROM U
LEFT JOIN KA ON KA.ID=U.KdArtiID
GROUP BY U.KdNr,U.VsaNr,U.Artikel,KA.VarBez,KA.Preisliste,IIF(U.ME='-','ST',U.ME),U.VW_IsoCode,U.FW_IsoCode,KA.VkPreis,KA.WaschPreis,KA.Leasingpreis_VTW,KA.BasisRestwert,KA.GesamtRestwert;