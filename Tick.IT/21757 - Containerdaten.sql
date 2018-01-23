DECLARE @Voecklabruck TABLE (Barcode nchar(8) COLLATE Latin1_General_CS_AS)
DECLARE @Container TABLE (Barcode nchar(8) COLLATE Latin1_General_CS_AS)

INSERT INTO @Voecklabruck VALUES (N'00103282'), (N'00105462'), (N'00105917'), (N'00109882'), (N'00112119'), (N'00113681'), (N'00114361'), (N'00118087'), (N'00200201'), (N'00300086'), (N'00300192'), (N'00300253'), (N'00300823'), (N'00301111'), (N'00301131'), (N'00301204'), (N'00301296'), (N'00301793'), (N'00301858'), (N'00301940'), (N'00302142'), (N'00302213'), (N'00302261'), (N'00302267'), (N'00302288'), (N'00303493'), (N'00303497'), (N'00104800'), (N'00105390'), (N'00109200'), (N'00112360'), (N'00113133'), (N'00117141'), (N'00117356'), (N'00200811'), (N'00301310'), (N'00301335'), (N'00301793'), (N'00302041'), (N'00302414'), (N'00302440'), (N'00101381'), (N'00103282'), (N'00105462'), (N'00108000'), (N'00108672'), (N'00109916'), (N'00110498'), (N'00114441'), (N'00120030'), (N'00200063'), (N'00200662'), (N'00200805'), (N'00300355'), (N'00300572'), (N'00300576'), (N'00300705'), (N'00300921'), (N'00300946'), (N'00301111'), (N'00301119'), (N'00301184'), (N'00301482'), (N'00301801'), (N'00301858'), (N'00301895'), (N'00301936'), (N'00301958'), (N'00302072'), (N'00302133'), (N'00302144'), (N'00302213'), (N'00302232'), (N'00302392'), (N'00302402'), (N'00302521'), (N'00302552'), (N'00302613'), (N'00303434'), (N'00400599'), (N'00104800'), (N'00105390'), (N'00112360'), (N'00117141'), (N'00117356'), (N'00200811'), (N'00301310'), (N'00302414')

INSERT INTO @Container
SELECT DISTINCT Barcode FROM @Voecklabruck

SELECT Contain.Barcode, RTRIM(CAST(Kunden.KdNr AS nchar(10))) + ' - ' + Kunden.SuchCode AS [zuletzt expediert zu Kunde], FORMAT(Contain.LetzteExp, 'G', 'de-AT') AS [zuletzt expediert], RTRIM(CAST(HistKunden.KdNr AS nchar(10))) + ' - ' + HistKunden.SuchCode AS [zuletzt gescannt bei Kunde], HistVsa.Bez AS [zuletzt gescannt bei VSA], Status = 
  CASE Contain.HistStatus
    WHEN 'A' THEN 'aus Wäscherei ausgegangen'
    WHEN 'a' THEN 'von VSA abgeholt'
    WHEN 'C' THEN 'geleert in Wäscherei'
    WHEN 'E' THEN 'in Wäscherei eingegangen'
    WHEN 'e' THEN 'bei VSA abgeladen'
    ELSE 'unbekannt'
  END, FORMAT(MAX(ContHist.Zeitpunkt), 'G', 'de-AT') AS [zuletzt gescannt]
FROM @Container AS c
LEFT OUTER JOIN Contain ON Contain.Barcode = c.Barcode
LEFT OUTER JOIN Vsa AS HistVsa ON Contain.HistVsaID = HistVsa.ID
LEFT OUTER JOIN Kunden AS HistKunden ON HistVsa.KundenID = HistKunden.ID
LEFT OUTER JOIN Kunden ON Contain.KundenID = Kunden.ID
LEFT OUTER JOIN ContHist ON ContHist.ContainID = Contain.ID
GROUP BY Contain.Barcode, RTRIM(CAST(Kunden.KdNr AS nchar(10))) + ' - ' + Kunden.SuchCode, Contain.LetzteExp, RTRIM(CAST(HistKunden.KdNr AS nchar(10))) + ' - ' + HistKunden.SuchCode, HistVsa.Bez, 
  CASE Contain.HistStatus
    WHEN 'A' THEN 'aus Wäscherei ausgegangen'
    WHEN 'a' THEN 'von VSA abgeholt'
    WHEN 'C' THEN 'geleert in Wäscherei'
    WHEN 'E' THEN 'in Wäscherei eingegangen'
    WHEN 'e' THEN 'bei VSA abgeladen'
    ELSE 'unbekannt'
  END

GO