DECLARE @Artikel nchar(15) = N'IGRIA3';
DECLARE @BereichID int = (SELECT BereichID FROM Artikel WHERE ArtikelNr = @Artikel);
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @Customer TABLE (
  KdNr int PRIMARY KEY
);

DECLARE @InsertedKdBer TABLE (
  KdBerID int PRIMARY KEY,
  KundenID int,
  VertragID int,
  ServiceID int,
  VertreterID int,
  BetreuerID int
);

DECLARE @KdArti TABLE (
  ID int PRIMARY KEY
);

INSERT INTO @Customer
VALUES (1062), (1063), (1100), (1132), (1265), (1270), (2003), (2022), (2024), (2025), (2029), (2034), (2035), (2245), (2273), (2276), (2281), (2288), (2290), (2300), (2301), (2303), (2306), (2373), (2374), (3113), (4052), (4054), (4056), (4057), (5005), (5010), (5014), (5016), (5021), (5063), (5066), (5069), (5151), (5153), (5154), (5159), (6020), (6060), (6065), (6070), (6071), (7001), (7005), (7008), (7012), (7014), (7020), (7022), (7023), (7024), (7025), (7052), (7185), (7240), (7244), (7255), (7278), (7282), (7308), (7370), (7371), (7425), (8022), (8023), (8024), (8025), (8026), (8027), (8030), (8031), (8060), (8066), (8101), (8131), (8267), (8268), (8887), (8888), (8889), (9005), (9013), (9022), (10016), (11002), (11009), (11010), (11050), (11100), (11101), (11102), (11110), (11140), (11150), (11156), (11208), (12008), (12020), (12065), (12077), (12090), (12095), (12176), (13320), (13330), (13331), (13394), (13422), (13430), (13500), (13950), (14003), (14020), (14030), (15001), (15002), (15005), (15007), (15075), (15100), (15200), (16030), (16031), (16035), (16041), (16078), (16081), (16084), (16085), (16151), (16176), (16250), (18001), (18022), (18027), (18029), (18030), (18032), (18033), (18045), (18074), (18078), (18083), (18084), (18085), (18087), (18088), (18089), (18093), (18094), (18096), (18100), (18101), (19000), (19001), (19005), (19006), (19007), (19009), (19010), (19011), (19012), (19013), (19015), (19016), (19021), (19022), (19023), (19024), (19026), (19027), (19030), (19042), (19043), (19044), (19048), (19049), (19051), (19052), (19053), (19054), (19055), (19056), (19057), (19058), (19059), (19060), (19063), (19064), (19068), (19080), (19081), (19111), (19129), (19159), (20000), (20010), (20015), (20018), (20025), (20026), (20041), (20042), (20045), (20084), (20085), (20124), (20125), (20126), (20130), (20140), (20142), (20143), (20144), (20145), (20146), (20150), (20153), (20156), (20157), (20160), (21090), (21091), (21093), (21100), (21144), (21146), (22003), (22013), (22020), (22025), (22068), (22080), (23007), (23010), (23031), (23032), (23036), (23037), (23041), (23042), (23044), (23046), (23047), (23048), (23999), (24040), (24041), (24045), (24090), (25005), (25007), (25008), (25028), (25033), (25034), (25043), (25100), (26003), (26004), (26005), (26007), (27000), (27001), (30026), (30027), (30028), (30045), (30049), (30055), (30056), (30061), (30066), (30067), (30075), (30078), (30081), (30092), (30125), (30233), (30234), (30237), (30256), (30291), (30319), (30341), (30349), (30393), (30433), (30480), (30508), (31048), (31199), (31200), (31203), (31204), (31207), (31208), (31209), (31210), (31211), (50001), (90001), (90002), (90004), (90006), (90008), (90009), (90010), (90011), (90013), (99994), (130042), (140055), (140057), (140084), (140143), (140235), (202948), (232257), (240891), (242036), (244842), (245994), (246487), (248183), (248198), (249203), (249204), (249205), (250675), (250912), (260752), (260838), (260839), (260858), (260903), (261172), (261662), (261903), (261950), (262000), (270138), (270250), (270444), (271127), (271790), (271908), (271909), (271910), (272012), (272728), (272783), (272993), (2340125), (10001002), (10001006), (10001143), (10001163), (10001166), (10001363), (10001365), (10001367), (10001370), (10001662), (10001671), (10001672), (10001754), (10001756), (10001770), (10001791), (10001792), (10001793), (10001794), (10001795), (10001799), (10001802), (10001804), (10001805), (10001810), (10001811), (10001812), (10001813), (10001814), (10001815), (10001816), (10001817), (10001822), (10001826), (10001828), (10001901), (10001902), (10001904), (10001910), (10001913), (10001925), (10001927), (10001928), (10001929), (10002017), (10002115), (10002311), (10002413), (10003222), (10003460), (10003461), (10003465), (10003466), (10003473), (10003674), (10003771), (10004093), (10004548), (10004549), (10004656), (10004871), (10004916), (10004964), (10005036), (10005060), (10005063), (10005091), (10005269), (10005365), (10005421), (10005477), (10005512), (10005566), (10005850), (10005865), (10005948), (10005990), (10006008), (10006012), (10006047), (10006095);

INSERT INTO KdBer ([Status], KundenID, BereichID, VertragID, FakFreqID, ServiceID, VertreterID, BetreuerID, RechKoServiceID, AnfAusEpo, AnlageUserID_, UserID_)
OUTPUT INSERTED.ID AS KdBerID, INSERTED.KundenID, INSERTED.VertragID, INSERTED.ServiceID, INSERTED.VertreterID, INSERTED.BetreuerID
INTO @InsertedKdBer (KdBerID, KundenID, VertragID, ServiceID, VertreterID, BetreuerID)
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
WHERE Kunden.KdNr IN (SELECT KdNr FROM @Customer)
  AND Kunden.Status = N'A'
  AND NOT EXISTS (
    SELECT KdBer.*
    FROM KdBer
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE Bereich.ID = @BereichID
      AND KdBer.KundenID = Kunden.ID
  );

INSERT INTO VsaBer ([Status], VsaID, KdBerID, VertragID, ServiceID, VertreterID, BetreuerID, AnfAusEpo, VsaTourUnnoetig, ErstFakLeas, ErstLS, AnlageUserID_, UserID_)
SELECT N'A' AS [Status], Vsa.ID AS VsaID, InsertedKdBer.KdBerID, InsertedKdBer.VertragID, InsertedKdBer.ServiceID, InsertedKdBer.VertreterID, InsertedKdBer.BetreuerID, 0 AS AnfAusEPo, 1 AS VsaTourUnnoetig, N'1980/01' AS ErstFakLeas, N'1980/01' AS ErstLs, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM @InsertedKdBer AS InsertedKdBer
JOIN Vsa ON InsertedKdBer.KundenID = Vsa.KundenID
WHERE Vsa.[Status] = N'A';

INSERT INTO KdArti ([Status], KundenID, ArtikelID, KdBerID, WaschPreis, LiefArtID, WaschPrgID, MaxWaschen, AnlageUserID_, UserID_)
OUTPUT inserted.ID INTO @KdArti (ID)
SELECT N'A' AS [Status], Kunden.ID AS KundenID, Artikel.ID AS ArtikelID, KdBer.ID AS KdBerID, CAST(190 AS money) AS Waschpreis, Artikel.LiefArtID, Artikel.WaschPrgID, Artikel.MaxWaschen, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM Kunden
CROSS JOIN Artikel
JOIN KdBer ON KdBer.KundenID = Kunden.ID AND KdBer.BereichID = Artikel.BereichID
WHERE Kunden.KdNr IN (SELECT KdNr FROM @Customer)
  AND Artikel.ArtikelNr = @Artikel
  AND Kunden.Status = N'A'
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    WHERE KdArti.ArtikelID = Artikel.ID
      AND KdArti.KundenID = Kunden.ID
  );

SELECT Kunden.KdNr, Kunden.Suchcode AS Kunde
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
WHERE KdArti.ID IN (SELECT ID FROM @KdArti);

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde
FROM Kunden
WHERE Kunden.KdNr IN (SELECT KdNr FROM @Customer)
  AND Kunden.Status = N'A'
  AND NOT EXISTS (
      SELECT KdArti.*
      FROM KdArti
      JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
      WHERE KdArti.KundenID = Kunden.ID
        AND Artikel.ArtikelNr = @Artikel
    )
  AND NOT EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.BereichID = (SELECT BereichID FROM Artikel WHERE ArtikelNr = @Artikel)
  );