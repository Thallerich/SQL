CREATE OR ALTER VIEW [sapbw].[UMLAUF_ALL]
AS
-- Umlauf DATUM = select CAST(DATEDIFF(DAY,1,GETDATE()-DATEDIFF(DAY,0,GETDATE())%7) AS DATETIME) -->> Letzte Sontag

-- 10.01.2023 Kirchberger Julia
-- (1) Korrektur MAX(Datum): Mit Max(Datum) wird immer nur der letzte Datensatz (ältestes Datum) auf 0 gestellt, 
--     es müssen Alle Datumswerte auf 0 gestellt werden
--     da Advantex keine Datensätze mit Bestand 0 liefert, müssen die Artikel mit Umlaufmengen der Vorwoche für die jeweilige Woche 
--     auf 0 gestellt werden, 
--     wenn ein Artikel bei einem Kunden nicht mehr in Verwendung ist, sonst bleibt der Altbestand stehen.
--	   Group By fällt damit weg
-- (2) Korrektur Preise: Bei der Query mit Max(Datum) waren die Preise für HRW und EUR 0, das ist falsch, weil die Anforderung war, 
--     dass der letztgültige Preis 
--     angezeigt werden soll, wenn der Bestand auf 0 gestellt wird und nicht ein Preis mit Wert 0. Cross Apply musste ergänzt werden
-- (3) Where Bedingung bei Umlaufmengen mit 0, da kein in der Zukunft liegendes Datum eingespielt werden soll.
-- (4) Sum über Umlaufmenge gemacht, da es sein Kann, dass Variante Artikel, VSA, Kunde pro Datum mehrmals vorkommt, 
--     die KdartiID aber unterschiedlich ist
-- (5) Die 0 Umlaufmengen eingeschränkt auf nur neue Datensätze. Where not exist ....
--     Bsp. 17.4.2022 für OWS VSA 900 gibt es keine Menge, deswegen werden beim 0-Query der 17.4. ausgegeben und davor keine Daten.
--     Beim Mengen-Query gibt es dazu keinen Datensatz, Datensätze davor aber schon
-- (6) 23.01.2023 Info von Attila Hajdu: Es werden nur Mengen benötigt, Preise werden aus direkt ADV abgefragt.

-- --> Anfang With Klausel -------------
WITH U AS (
  SELECT _U.Datum,
		K.KdNr,
		V.VsaNr,
		_U.KdArtiID,
		UPPER(A.ArtikelNr+IIF(ISNULL(REPLACE(AG.Groesse,'"',''),'-')='-','','-'+REPLACE(AG.Groesse,'-','/'))) AS Artikel,
		SUM(_U.Umlauf) Umlauf,
		M.IsoCode ME
	FROM Salesianer.dbo._Umlauf _U
	JOIN Salesianer.dbo.VSA V ON V.ID=_U.VsaID
	JOIN Salesianer.dbo.ARTIKEL A ON A.ID=_U.ArtikelID
	JOIN Salesianer.dbo.ME M ON A.MEID=M.ID
	JOIN Salesianer.dbo.Kunden K ON V.KundenID=K.ID
	LEFT JOIN Salesianer.dbo.ARTGROE AG ON AG.ID=_U.ArtGroeID
	WHERE A.ArtiTypeID=1 -->> Textile Artikel
		AND K.AdrArtID=1 -->> nur Kunde
	GROUP BY _U.Datum,K.KdNr,V.VsaNr,_U.KdArtiID,A.ArtikelNr,M.IsoCode, AG.Groesse, K.ID
),
VB AS (
	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) Pos, value VarBez
	FROM STRING_SPLIT(N'GEF-A,GEF-H,GEF-1,GEF-3,GEF-4,HANG,UNGEF,1W,2W,3W,4W,12W,24W,8W,99W,6W,26W,16W,32W,52W,SPEZWN,SPL-A,SPL-H,CHEM,FOLIE,GYN,MTLKA,QUER,OBEN,ET,RUDI,LAENGS,AUVA,KORNB,KE,KE-HA,KE-H,EXPR,VE/100,-',',')
),
KA AS (
	SELECT ID,KundenId,KdBerID,VkPreis,WaschPreis,BasisRestwert,GesamtRestwert, STRING_AGG(VB.VarBez,',') WITHIN GROUP (ORDER BY VB.Pos ASC) VarBez, LeasPreis.LeasPreisProWo AS Leasingpreis_VTW, CAST(IIF(KDA.LeasPreisPrListKdArtiID > 0 OR KDA.WaschPreisPrListKdArtiID > 0, 1, 0) AS bit) AS Preisliste
	FROM Salesianer.dbo.KDARTI KDA
  CROSS APPLY Salesianer.dbo.advFunc_GetLeasPreisProWo(KDA.ID) AS LeasPreis
	LEFT JOIN VB ON KDA.VariantBez LIKE '%('+VB.VarBez+')%'
	GROUP BY ID,KundenId,KdBerID,VariantBez,VkPreis,WaschPreis,BasisRestwert,GesamtRestwert, LeasPreis.LeasPreisProWo, CAST(IIF(KDA.LeasPreisPrListKdArtiID > 0 OR KDA.WaschPreisPrListKdArtiID > 0, 1, 0) AS bit)
)
-- --> Ende   With Klausel -------------
-- --> Anfang Abfrage      -------------
Select Datum, KdNr, VsaNr, Artikel, Variante, Preisliste, SUM(Umlauf) Umlauf, ME
from (
  SELECT U.Datum,
    U.KdNr,
    U.VsaNr,
    U.Artikel,
    KA.VarBez Variante,
    KA.Preisliste,
    sum(U.Umlauf) as Umlauf,
    IIF(U.ME='-','ST',U.ME) ME
  FROM U
  LEFT JOIN KA ON KA.ID=U.KdArtiID
  group by U.Datum,
    U.KdNr,
    U.VsaNr,
    U.Artikel,
    KA.VarBez,
    KA.Preisliste,
    IIF(U.ME='-','ST',U.ME)

  UNION ALL --ADV UMLAUF=ZERO: letzte Datum + 7 Tage, Umlauf=ZERO
  SELECT --DATEADD(DAY,7,MAX(U.Datum)) Datum,
    DATEADD(DAY,7,U.Datum) Datum,
    U.KdNr,
    U.VsaNr,
    U.Artikel,
    KA.VarBez Variante,
    KA.Preisliste,
    0 Umlauf,
    IIF(U.ME='-','ST',U.ME) ME
  FROM U
  LEFT JOIN KA ON KA.ID=U.KdArtiID
) Umlauf
group by Datum, KdNr, VsaNr, Artikel, Variante, Preisliste, ME;