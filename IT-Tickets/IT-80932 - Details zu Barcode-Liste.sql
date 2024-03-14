DECLARE @BarcodeList TABLE (
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS
);

INSERT INTO @BarcodeList (Barcode)
VALUES ('2080735339'), ('2079387679'), ('2080699075'), ('2081491098'), ('2079389475'), ('2079389680'), ('2079387938'), ('2079389567'), ('2079389659'), ('2079389338'), ('2079389390'), ('2079387648'), ('2079389369'), ('2079388096'), ('2079387983'), ('2079387990'), ('2079387396'), ('2079389697'), ('2079387976'), ('2080550390'), ('2079389499'), ('2079388041'), ('2079388119'), ('2079388027'), ('2074733525'), ('2079387655'), ('2079387907'), ('2080698269'), ('2080697569'), ('2083638255'), ('2083638118'), ('2083638156'), ('2083638064'), ('2083638095'), ('2080618144'), ('2081493733'), ('2081491081'), ('2080885546'), ('2080906937'), ('2080906050'), ('2080907972'), ('2074600421'), ('2080905138'), ('2074601145'), ('2080905404'), ('2080907620'), ('2080906821'), ('2080907545'), ('2080906715'), ('2080907514'), ('2080906029'), ('2074600599'), ('2080907835'), ('2080908139'), ('2080908078'), ('2074600025'), ('2074600490'), ('2080907521'), ('2080905060'), ('2080906135'), ('2080905374'), ('2080905183'), ('2080905152'), ('2071457660'), ('2079480325'), ('2079480301'), ('2079480431'), ('2079481568'), ('2079480011'), ('2079480066'), ('2079480561'), ('2079480509'), ('2079480486'), ('2079480370'), ('2079481476'), ('2079480219'), ('2053127581'), ('2036243000'), ('2071458001'), ('2071457080'), ('2083635711'), ('2083636138'), ('2083635858'), ('2083635902'), ('2079480943'), ('2083636404'), ('2081861693'), ('2081490343'), ('2081860917'), ('2034071742'), ('2002770028'), ('2004553216'), ('2079389116'), ('2079388768'), ('2079388751'), ('2079388799'), ('2079389895'), ('2079389161'), ('2079389024'), ('2079385910'), ('2079389192'), ('2079386658'), ('2079386474'), ('2079385781'), ('2079385774'), ('2079386436'), ('2079386214'), ('2079386313'), ('2079387433'), ('2079385613'), ('2079385750'), ('2029286953'), ('1359413701'), ('2029287615'), ('2080619097'), ('2054862737'), ('2081250138'), ('2080617222'), ('2080617277'), ('2081493443'), ('2071468130'), ('2080550581'), ('2080550550'), ('2080550949'), ('2079389949'), ('2017986100'), ('2074976359'), ('2075207643'), ('2075208268'), ('2075206462'), ('2075205991'), ('2075208220'), ('2074976274'), ('2075510828'), ('2075207667'), ('2075207674'), ('2075207681'), ('2075207582'), ('2075208282'), ('2074976335'), ('2075510859'), ('2075510934'), ('2075206004'), ('2075205755'), ('2055385682'), ('2055385712'), ('2055385392'), ('2055385576'), ('2055385538'), ('2055385668');

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'EINZHIST'
)
SELECT EinzHist.Barcode,
  Teilestatus.StatusBez AS [Status],
  EinzHist.Eingang1 AS [letzter Eingang],
  EinzHist.Ausgang1 AS [letzter Ausgang],
  [Lieferschein-Nr] = (
    SELECT LsKo.LsNr
    FROM LsKo
    WHERE LsKo.ID = (SELECT LsPo.LsKoID FROM LsPo WHERE LsPo.ID = EinzHist.LastLsPoID)
  ),
  EinzTeil.LastScanTime AS [letzter Scan-Zeitpunkt],
  Actions.ActionsBez AS [letzte Aktion],
  ZielNr.ZielNrBez AS [letzter Produktions-Ort],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse,
  Traeger.Traeger,
  Traeger.Vorname,
  Traeger.Nachname,
  Vsa.VsaNr,
  Vsa.Bez AS [Vsa-Bezeichnung],
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde
FROM EinzHist
JOIN EinzTeil ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Actions ON EinzTeil.LastActionsID = Actions.ID
JOIN ZielNr ON EinzTeil.ZielNrID = ZielNr.ID
JOIN Teilestatus ON EinzHist.[Status] = Teilestatus.[Status]
WHERE EinzHist.Barcode IN (
  SELECT Barcode
  FROM @BarcodeList
);

GO