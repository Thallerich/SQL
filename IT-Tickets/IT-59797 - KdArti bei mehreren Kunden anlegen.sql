DECLARE @ArticleNumber nvarchar(15) = N'VMISS1';
DECLARE @BereichID int = (SELECT BereichID FROM Artikel WHERE ArtikelNr = @ArticleNumber);
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @Customer TABLE (
  CustomerNumber int PRIMARY KEY
);

INSERT INTO @Customer (CustomerNumber)
VALUES (261662), (270250), (10001826), (10001927), (23031), (23032), (23036), (23037), (23041), (23042), (23044), (23046), (23047), (23048), (15005), (19060), (2300), (2301), (2303), (2306), (6060), (10002311), (10002413), (260838), (260839), (260858), (261903), (10001006), (10006095), (5151), (5153), (5154), (7001), (7005), (7008), (7012), (7014), (7022), (7023), (7024), (7025), (1000), (1004), (1013), (1018), (1020), (1023), (1026), (1028), (1029), (1031), (1032), (1033), (1034), (1038), (1039), (1071), (1073), (1075), (1076), (1077), (1079), (1081), (1082), (1083), (1100), (1255), (2003), (2004), (2005), (2034), (2245), (2273), (2276), (2281), (2373), (2374), (4052), (4054), (4057), (4059), (4061), (5021), (5063), (5069), (5159), (5186), (6065), (7052), (7185), (7244), (7255), (7278), (7282), (7308), (8268), (9005), (9022), (10002), (10004), (11002), (11009), (11010), (11110), (11208), (12008), (12065), (12090), (12095), (13394), (13422), (13500), (14020), (15100), (16081), (16084), (16085), (16176), (18022), (18032), (18999), (19005), (19015), (19022), (19026), (19027), (19042), (19043), (19044), (19048), (19049), (19051), (19052), (19063), (19064), (19081), (20018), (20026), (20041), (20042), (20045), (20124), (20125), (20126), (20130), (20157), (21144), (22020), (22068), (23007), (23999), (24040), (24041), (25005), (25043), (26005), (27000), (27001), (29999), (30026), (30027), (30028), (30066), (30067), (30078), (30081), (30082), (30125), (30237), (30256), (30433), (30480), (30488), (30508), (31199), (90001), (90002), (90004), (90006), (90008), (90009), (90010), (90011), (90013), (99994), (140084), (202948), (240891), (246487), (249203), (249204), (249205), (2340125), (10001002), (10001143), (10001163), (10001166), (10001770), (10001791), (10001792), (10001793), (10001795), (10001904), (10002017), (10003222), (10004093), (10004656), (10005036), (10005091), (10005269), (10005850), (10005865), (10006012), (6071), (7240), (9013), (11050), (18045), (20000), (21093), (24045), (10004964), (2022), (18001), (262000), (10004916), (1062), (1063), (8131), (20084), (20085), (21146), (30049), (8887), (8888), (8889), (50001), (10001671), (10001672), (10001799), (10001802), (10001804), (10001805), (10001810), (10001811), (10001812), (10001813), (10001814), (10001815), (10001816), (10001817), (10001822), (271127), (245994), (250675), (250912), (270138), (271908), (271909), (271910), (272783), (10003674), (2024), (7425), (8022), (8023), (8024), (8025), (8026), (8027), (19016), (23010), (25008), (25033), (30061), (10005477), (260752), (260903), (261172), (10001925), (15200), (15001), (15007), (16078), (30393), (30055), (30056), (271790), (272012), (3113), (25007), (10004871), (10005512), (31200), (31203), (31204), (31207), (31208), (31209), (31210), (31211), (232257), (13950), (21100), (30319), (30291), (30341), (30349), (26003), (26004), (242036), (272993), (10003460), (10003461), (10003465), (10003466), (10003473), (10003771), (10005566), (10006008), (10001363), (10001365), (10001367), (10001370), (10001901), (10001902), (10001910), (10001913), (10004548), (10004549), (30233), (30234), (4056), (130042), (31048), (10005421), (10006047), (18000), (244842), (10002115), (18074), (18078), (18083), (18084), (18085), (18087), (18088), (18089), (18093), (18094), (18096), (18100), (18101), (30045), (8030), (8031), (8101), (10016), (13331), (16250), (19053), (19054), (22003), (25028), (25034), (10005365), (272728), (261950), (6020), (19000), (19001), (19006), (19007), (19009), (19010), (19011), (19012), (19013), (19023), (19024), (19030), (270444), (10001662), (10001754), (10001756), (10001928), (1132), (2288), (2290), (5010), (13330), (15075), (5014), (8060), (6070), (12077), (16151), (5005), (20025), (7020), (7371), (11140), (16041), (11150), (11156), (25100), (5066), (8066), (8267), (12176), (14003), (21090), (21091), (22080), (2029), (7370), (16030), (16031), (16035), (20015), (5016), (15002), (18030), (1265), (19111), (20010), (26007), (10005948), (2025), (2035), (19068), (22025), (30075), (30092), (1270), (14030), (24090), (12020), (13320), (22013), (140055), (140057), (140143), (140235), (10005060), (11100), (11101), (11102), (13430), (19021), (19055), (19056), (19057), (19058), (19059), (10001794), (248183), (248198), (18027), (18029), (18033), (19080), (19129), (19159), (20140), (20142), (20143), (20144), (20145), (20146), (20150), (20153), (20156), (20160), (10005063), (10005990), (10001828), (10001929);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Kunden ohne korrekten Vertrag ermitteln und ausgeben für Rückmeldung -> manuelle Arbeit notwendig!                        ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde
  FROM Kunden
  WHERE Kunden.KdNr IN (SELECT CustomerNumber FROM @Customer)
    AND NOT EXISTS (
      SELECT KdBer.*
      FROM KdBer
      WHERE KdBer.BereichID = @BereichID
        AND KdBer.KundenID = Kunden.ID
    )
    AND NOT EXISTS (
      SELECT Vertrag.*
      FROM Vertrag
      WHERE Vertrag.BereichID IN (-1, @BereichID)
        AND Vertrag.Status = N'A'
        AND Vertrag.KundenID = Kunden.ID
    );

BEGIN TRANSACTION;

  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
  /* ++ Kundenbereiche anlegen wo noch nicht vorhanden                                                                            ++ */
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
  INSERT INTO KdBer ([Status], KundenID, BereichID, VertragID, FakFreqID, ServiceID, VertreterID, BetreuerID, RechKoServiceID, AnfAusEpo, AnlageUserID_, UserID_)
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
  WHERE Kunden.KdNr IN (SELECT CustomerNumber FROM @Customer)
    AND NOT EXISTS (
      SELECT KdBer.*
      FROM KdBer
      WHERE KdBer.BereichID = @BereichID
        AND KdBer.KundenID = Kunden.ID
    )
    AND EXISTS (
      SELECT Vertrag.*
      FROM Vertrag
      WHERE Vertrag.BereichID IN (-1, @BereichID)
        AND Vertrag.Status = N'A'
        AND Vertrag.KundenID = Kunden.ID
    );

  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
  /* ++ Kundenartikel anlegen wo noch nicht vorhanden                                                                             ++ */
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
  INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, LiefArtID, WebArtikel, Waschpreis, AnlageUserID_, UserID_)
  SELECT DISTINCT N'A' AS [Status], Kunden.ID AS KundenID, ArtikelNeu.ID AS ArtikelID, KdBer.ID AS KdBerID, 4 AS LiefArtID, 0 AS WebArtikel, 190 AS Waschpreis, @UserID AS AnlageUserID_, @UserID AS UserID_
  FROM Kunden
  JOIN KdBer ON KdBer.KundenID = Kunden.ID
  JOIN (
    SELECT Artikel.ID, Artikel.BereichID
    FROM Artikel
    WHERE Artikel.ArtikelNr = @ArticleNumber
  ) AS ArtikelNeu ON ArtikelNeu.BereichID = KdBer.BereichID
  WHERE Kunden.KdNr IN (SELECT CustomerNumber FROM @Customer)
    AND NOT EXISTS (
      SELECT KdArti.*
      FROM KdArti
      WHERE KdArti.KundenID = Kunden.ID
        AND KdArti.ArtikelID = ArtikelNeu.ID
    );

COMMIT;