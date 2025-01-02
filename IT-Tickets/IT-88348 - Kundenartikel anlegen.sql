DECLARE @ArtikelID int, @BereichID int, @LiefArtID int, @VertragNr int;
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE MitarbeiUser = N'THALST');
SELECT @ArtikelID = ID, @BereichID = BereichID, @LiefArtID = LiefArtID FROM Artikel WHERE ArtikelNr = N'7101EX';
SELECT @VertragNr = (SELECT MAX(Vertrag.Nr) FROM Vertrag);

DECLARE @Kundenliste TABLE (
  KdNr int
);

DECLARE @VertragMissing TABLE (
  KundenID int,
  AddNr int
);

DECLARE @KdArtiInsert TABLE (
  KdArtiID int
);

INSERT INTO @Kundenliste (KdNr)
VALUES (801124), (820413), (801183), (810632), (840240), (822005), (821702), (830079), (860231), (801015), (850121), (822207), (830571), (822083), (830456), (801116), (815048), (821354), (860292), (820099), (811615), (860302), (850251), (801007), (850053), (850156), (821979), (821976), (821982), (821156), (801112), (801147), (840090), (821684), (820991), (815019), (810233), (822096), (810666), (822013), (811006), (815039), (820071), (810313), (822029), (810408), (830010), (822137), (822020), (821727), (822006), (801078), (801127), (820045), (860295), (850274), (811071), (821456), (821807), (821808), (899941), (821707), (801128), (821443), (821839), (822202), (820903), (821716), (830875), (821479), (822025), (800432), (810443), (822170), (822139), (821782), (815022), (821451), (821105), (810915), (821013), (821776), (821931), (815051), (801010), (810914), (811641), (801120), (801136), (811279), (822021), (821666), (810253), (815046), (821939), (811024), (821358), (821414), (860241), (850037), (822000), (821392), (850142), (850202), (860334), (821822), (830860), (811276), (820144), (811069), (820137), (801121), (821779), (821988), (840100), (850113), (800771), (821932), (821341), (899004), (801125), (801139), (840241), (815028), (815029), (830429), (801119), (821995), (840224), (840227), (810302), (850000), (850035), (811253), (800067), (801045), (821412), (811650), (820053), (815040), (815047), (860296), (815033), (811265), (821772), (860297), (820233), (860336), (821687), (801043), (820561), (850114), (821992), (860333), (850112), (850252), (821366), (830797), (815020), (821656), (850230), (811247), (850134), (821199), (830129), (850115), (821162), (821077), (830197), (815017), (810421), (821860), (822278), (850120), (821917), (850132), (821041), (821999), (822014), (801087), (811580), (821525), (821986), (821987), (821993), (815023), (821445), (860188), (850259), (850118), (800037), (850254), (822127), (850165), (850219), (860224), (850258), (822126), (820859), (820937), (821700), (811592), (801098), (801075), (860005), (860003), (840101), (811280), (821792), (821487), (821505), (821466), (821429), (822281), (810216), (860233), (811266), (811267), (822024), (810397), (810950), (821774), (821783), (800613), (821464), (810879), (801088), (821102), (820353), (821561), (811021), (811022), (810374), (860312), (899991), (850061), (850063), (850065), (850173), (850179), (850208), (850211), (850264), (850261), (850262), (850263), (850265), (850266), (850267), (850268), (850269), (850270), (850271), (850272), (850273), (850275), (850276), (850277), (850278), (850279), (850280), (850281), (850282), (850283), (850284), (850285), (850286), (850287), (850288), (860299), (860300), (860301), (822023), (821402), (821867), (830311), (860311), (820022), (822016), (899005), (860236), (801094), (810412), (810308), (815038), (840097), (811026), (821494), (860006), (821625), (811258), (811278), (810647), (810144), (811632), (801077), (801018), (860035), (810916), (810957), (860167), (860066), (860106), (860007), (850136), (850047), (850045), (850046), (801008), (810942), (810926), (801027), (821056), (860009), (810881), (810924), (820048), (815049), (815031), (811283), (811284), (850176), (810238), (810963), (860298), (821581), (860171), (801129), (214458), (810159), (801084), (800748), (821990), (899938), (822101), (821866), (840230), (850183), (850184), (850185), (850186), (850187), (850188), (850189), (850190), (850191), (850192), (850193), (850194), (850195), (850199), (850200), (850203), (850205), (850214), (850216), (850217), (850218), (850225), (850231), (850232), (850234), (850182), (820518), (850181), (850220), (801177), (840095), (822015), (810665), (820806), (821616), (850122), (850123), (850124), (821978), (821732), (821360), (820459), (820644), (822028), (820204), (821322), (820524), (830493), (860010), (820165), (820316), (821374), (821386), (830572), (821385), (820819), (821380), (822103), (820210), (811012), (811014), (811252), (850236), (850238), (850239), (850240), (850241), (850242), (850243), (850237), (850244), (850245), (850246), (850247), (850248), (850249), (850250), (850253), (850255), (850256), (850257), (800740), (899961), (811599), (810281), (821212), (850147), (822017), (860189), (821634), (810349), (850224), (860332), (800517), (811002), (821714), (821640), (800998), (850048), (899956), (811616), (810278), (811588), (811244), (810972), (810971), (840239), (810101), (800979), (860240), (810630), (821686), (899000), (821448), (840200), (840228), (840229), (810109), (860011), (821858), (821859), (822211), (821657), (800458), (850145), (821821), (860012), (840221), (840092), (820727), (820744), (821576), (811282), (801062), (811011), (811070), (810940), (821934), (821823), (821463), (850204), (810158), (811257), (810943), (811009), (821567), (860303), (822027), (850129), (860227), (801049), (860173), (860229), (860234), (860280), (860242), (860232), (821609), (821591), (821983), (821781), (830857), (821197), (820950), (821461), (820565), (860282), (811023), (811585), (815041), (860322), (800313), (830623), (801082), (811057), (815036), (810986), (821601), (822284), (821548), (801032), (815042), (820238), (822227), (822235), (821276), (821501), (821516), (850180), (860132), (810637), (860153), (821353), (821460), (810230), (815037), (810327), (820329), (850144), (840238), (811630), (815030), (815021), (800223), (821659), (822111), (810282), (821726), (821725), (821004), (821923), (821998), (860294), (899989), (822026), (830535), (860331), (850260), (822113), (821522), (830094), (821924), (860281), (821916), (801132), (821994), (840083), (800104), (810955), (800080), (811581), (821980), (811637), (800996), (800155), (800288), (800497), (800583), (801152), (801022), (801174), (800105), (801034), (811643), (830861), (899002), (801081), (810440), (810656), (811003), (821372), (821804), (830859), (821440), (801021), (821401), (860237), (850221), (815016), (801097), (820790), (822121), (850175), (810616), (820712), (821378), (860137), (899974), (899936), (801009), (850108), (800770), (821989), (860136), (822081), (822082), (821033), (821638), (810086), (810911), (810959), (822001), (821790), (811237), (815052), (801017), (800181), (801182), (830048), (815032), (811250), (821863), (850017), (860019), (800000), (821704), (822105), (822106), (822011), (821736), (822030), (830877), (850159), (821668), (821802), (811246), (821482), (821815), (822183), (850148), (860323), (801113), (821606), (801100), (821284), (850174), (822018), (821810), (821630), (821698), (821731), (860021), (850215), (822022), (899065), (822009), (899976), (850209), (850235), (810604), (820267), (801030), (860023), (899003), (860024), (850060), (815045), (821708), (800542), (821411), (821446), (821715), (810311), (815050), (830704), (801065), (850201), (800113), (811600), (821996), (801131), (850141), (821478), (801117), (820668), (822208), (822215), (821574), (811255), (810410), (822114), (801114), (821570), (821565), (822019), (821812), (860293), (821664), (821665);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kunden-Tabelle aufbauen; diese Kunden sollen Containermiete (ohne Preis) auf der Rechnung bekommen                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @Kunden TABLE (
  KundenID int
);

INSERT INTO @Kunden (KundenID)
SELECT Kunden.ID AS KundenID
FROM Kunden
WHERE Kunden.KdNr IN (SELECT KdNr FROM @Kundenliste)
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.ArtikelID = @ArtikelID
      AND KdArti.KundenID = Kunden.ID
  )
  AND EXISTS (
    SELECT Vertrag.*
    FROM Vertrag
    WHERE Vertrag.KundenID = Kunden.ID
      AND Vertrag.[Status] = N'A'
  );  

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Verträge anlegen                                                                                                          ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO @VertragMissing (KundenID, AddNr)
SELECT DISTINCT KundenID, DENSE_RANK() OVER (ORDER BY KundenID) AS AddNr
FROM Vertrag
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
WHERE Kunden.KdNr IN (SELECT KdNr FROM @Kundenliste)
  AND Vertrag.Status = N'A'
  AND NOT EXISTS (
    SELECT V.ID
    FROM Vertrag AS V
    WHERE V.BereichID IN (-1, @BereichID)
      AND V.Status = N'A'
      AND V.KundenID = Vertrag.KundenID
  );

INSERT INTO Vertrag (KundenID, Bez, [Status], Nr, VertTypID, VertragAbschluss, VertragStart, VertragEnde, VertragFristErst, VertragFrist, VertragVerlaeng, Preisgarantie, AbschlussID, StartGruID, EingabeDatum, BereichID, PrLaufID, VertragAnlageID, VertragBearbeiID, AnlageUserID_, UserID_)
SELECT VertragMissing.KundenID, N'Handelsware' AS Bez, N'A' AS [Status], @VertragNr + VertragMissing.AddNr AS Nr, Vertrag.VertTypID, Vertrag.VertragAbschluss, Vertrag.VertragStart, Vertrag.VertragEnde, Vertrag.VertragFristErst, Vertrag.VertragFrist, Vertrag.VertragVerlaeng, Vertrag.Preisgarantie, Vertrag.AbschlussID, Vertrag.StartGruID, Vertrag.EingabeDatum, @BereichID AS BereichID, Vertrag.PrLaufID, Vertrag.VertragAnlageID, Vertrag.VertragBearbeiID, @userid AS AnlageUserID_, @userid AS UserID_
FROM @VertragMissing AS VertragMissing
JOIN (
  SELECT DENSE_RANK() OVER (PARTITION BY Vertrag.KundenID ORDER BY Vertrag.ID DESC) AS SortOrder, Vertrag.*
  FROM Vertrag
  WHERE Vertrag.[Status] = N'A'
) AS Vertrag ON Vertrag.KundenID = VertragMissing.KundenID
WHERE Vertrag.SortOrder = 1;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kundenbereich Sonstiges anlegen, falls noch nicht vorhanden                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @InsertedKdBer TABLE (
  KdBerID int,
  KundenID int,
  VertragID int,
  ServiceID int,
  VertreterID int,
  BetreuerID int
);

INSERT INTO KdBer ([Status], KundenID, BereichID, VertragID, FakFreqID, ServiceID, VertreterID, BetreuerID, RechKoServiceID, AnfAusEpo, AnlageUserID_, UserID_)
OUTPUT INSERTED.ID AS KdBerID, INSERTED.KundenID, INSERTED.VertragID, INSERTED.ServiceID, INSERTED.VertreterID, INSERTED.BetreuerID
INTO @InsertedKdBer
SELECT N'A' AS [Status], Kunden.ID AS KundenID, @BereichID AS BereichID, VertragID = (
    SELECT TOP 1 Vertrag.ID
    FROM Vertrag
    WHERE Vertrag.BereichID IN (-1, @BereichID)
      AND Vertrag.Status = N'A'
      AND Vertrag.KundenID = Kunden.ID
    ORDER BY Vertrag.Anlage_ DESC
  ), FakFreqID = (
    SELECT TOP 1 KdBer.FakFreqID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.FakFreqID
    ORDER BY COUNT(KdBer.ID)
  ), ServiceID = (
    SELECT TOP 1 KdBer.ServiceID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.ServiceID
    ORDER BY COUNT(KdBer.ID)
  ), VertreterID = (
    SELECT TOP 1 KdBer.VertreterID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.VertreterID
    ORDER BY COUNT(KdBer.ID)    
  ), BetreuerID = (
    SELECT TOP 1 KdBer.BetreuerID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.BetreuerID
    ORDER BY COUNT(KdBer.ID)
  ), RechKoServiceID = (
    SELECT TOP 1 KdBer.RechKoServiceID
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY KdBer.RechKoServiceID
    ORDER BY COUNT(KdBer.ID)
  ),
  0 AS AnfAusEPo, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM Kunden
WHERE Kunden.ID IN (SELECT KundenID FROM @Kunden)
  AND NOT EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.BereichID = @BereichID
      AND KdBer.KundenID = Kunden.ID
  );

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ VSA-Bereiche anlegen bei allen VSAs der Kunden, für die im vorigen Schritt der Kundenbereich angelegt wurde               ++ */
/* ++ TODO: VSA-Bereich auch bei Kunden anlegen, wo der Kundenbereich bereits existierte,                                       ** */
/* ++       aber bei einigen VSAs der Bereich fehlt                                                                             ** */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO VsaBer ([Status], VsaID, KdBerID, VertragID, ServiceID, VertreterID, BetreuerID, AnfAusEpo, VsaTourUnnoetig, ErstFakLeas, ErstLS, AnlageUserID_, UserID_)
SELECT N'A' AS [Status], Vsa.ID AS VsaID, InsertedKdBer.KdBerID, InsertedKdBer.VertragID, InsertedKdBer.ServiceID, InsertedKdBer.VertreterID, InsertedKdBer.BetreuerID, 0 AS AnfAusEPo, 1 AS VsaTourUnnoetig, N'1980/01' AS ErstFakLeas, N'1980/01' AS ErstLs, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM @InsertedKdBer AS InsertedKdBer
JOIN Vsa ON InsertedKdBer.KundenID = Vsa.KundenID
WHERE Vsa.[Status] = N'A';

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Spezialartikel CONTMIET mit Preis = 0 als Kundenartikel anlegen, falls noch nicht vorhanden                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, LiefArtID, AfaWochen, AnlageUserID_, UserID_)
OUTPUT inserted.ID INTO @KdArtiInsert (KdArtiID)
SELECT N'A' AS [Status], Kunden.ID AS KundenID, @ArtikelID AS ArtikelID, KdBer.ID AS KdBerID, @LiefArtID AS LiefArtID, 208 AS AfaWochen, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM Kunden
JOIN KdBer ON KdBer.KundenID = Kunden.ID
WHERE Kunden.ID IN (SELECT KundenID FROM @Kunden)
  AND KdBer.BereichID = @BereichID
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.KundenID = Kunden.ID
      AND KdArti.ArtikelID = @ArtikelID
  );

INSERT INTO PrArchiv (KdArtiID, Datum, MitarbeiID, Aktivierungszeitpunkt, AnlageUserID_, UserID_)
SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM @KdArtiInsert;

SELECT KdNr
FROM @Kundenliste AS Kundenliste
WHERE EXISTS (
  SELECT KdArti.*
  FROM KdArti
  JOIN Kunden ON KdArti.KundenID = Kunden.ID
  WHERE Kunden.KdNr = Kundenliste.KdNr
    AND KdArti.ArtikelID = @ArtikelID
    AND Kunden.Status = N'A'
)