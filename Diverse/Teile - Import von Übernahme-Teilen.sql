DECLARE @UserID int = (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'STHA');

INSERT INTO Teile (Barcode, [Status], VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Eingang1, Ausgang1, Entnommen, EinsatzGrund, PatchDatum, Erstwoche, ErstDatum, Indienst, IndienstDat, RuecklaufG, RuecklaufK, Kostenlos, AlterInfo, AltenheimModus, UebernahmeCode, AnlageUserID_, UserID_)
SELECT TB.BCNeu AS Barcode, N'Q' AS [Status], Vsa.ID AS VsaID, Traeger.ID AS TraegerID, TraeArti.ID AS TraeArtiID, KdArti.ID AS KdArtiID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, NULL AS Eingang1, NULL AS Ausgang1, 1 AS Entnommen, N'3' AS EinsatzGrund, CAST(GETDATE() AS date) AS PatchDatum, CAST(YEAR(TB.Erstdatum) AS nchar(4)) + N'/' + IIF(DATEPART(week, TB.Erstdatum) < 10, N'0' + CAST(DATEPART(week, TB.Erstdatum) AS nchar(1)), CAST(DATEPART(week, TB.Erstdatum) AS nchar(2))) AS ErstWoche, TB.ErstDatum, (SELECT Week.Woche FROM Week WHERE GETDATE() BETWEEN VonDat and BisDat) AS Indienst, CAST(GETDATE() AS date) AS InDienstDat, TB.Ruecklauf AS RuecklaufG, TB.Ruecklauf AS RuecklaufK, 0 AS Kostenlos, 0 AS AlterInfo, 0 AS AlteinheimModus, TB.Barcode AS UebernahmeCode, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM __TeileBilfinger AS TB
JOIN Kunden ON TB.KdNr = Kunden.KdNr
JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = TB.VsaNr
JOIN Traeger ON Traeger.VsaID = Vsa.ID AND Traeger.Traeger = TB.Traeger AND Traeger.Vorname = TB.Vorname AND Traeger.Nachname = TB.Nachname
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID AND Artikel.ArtikelNr = TB.ArtikelNr
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID AND ArtGroe.Groesse = TB.Groesse;