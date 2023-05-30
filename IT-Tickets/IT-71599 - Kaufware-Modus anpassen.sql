/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ 0 = keine Kaufware                                                                                                        ++ */   
/* ++ 1 = Kaufware mit Waschauftrag                                                                                                ++ */
/* ++ 2 = Kaufware ohne Waschauftrag                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
DECLARE @KaufwareModus int = 1;
DECLARE @KdNr int = 5001;
DECLARE @TraegerNr nchar(8) = N'0225';

DECLARE @TraeArtiKauf TABLE (
  TraeArtiID int PRIMARY KEY CLUSTERED
);

INSERT INTO @TraeArtiKauf (TraeArtiID)
SELECT TraeArti.ID
FROM TraeArti
JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.KdNr = @KdNr
  AND Traeger.Traeger = @TraegerNr
  AND TraeArti.KaufwareModus = 0;

UPDATE EinzHist SET KaufwareModus = @KaufwareModus
WHERE EinzHist.TraeArtiID IN (SELECT TraeArtiID FROM @TraeArtiKauf)
  AND EinzHist.KaufwareModus != @KaufwareModus;

UPDATE TraeArti SET KaufwareModus = @KaufwareModus
WHERE ID IN (SELECT TraeArtiID FROM @TraeArtiKauf);