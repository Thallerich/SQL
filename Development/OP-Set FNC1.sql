/* CHAR(210) for Barcode-Typ Code 128 Encoding C */
/* CHAR(207) --> FNC1 special character before every application identifier */

SELECT [KDNR] AS KdNr,
  N'[VSABEZ]' AS VsaBez,
  OPStueckliste.AnzPos, 
  OPCharge.ChargeNr, 
  CAST(OPCharge.Zeitpunkt AS date) Sterildatum, 
  /* 
    EAN Barcode (insgesamt 46 Stellen)
    Immer beginnend mit Application Identifier 01
    Danach der 13-stellige EAN-Nummer aus Artikelstamm mit vorangestellter 0
    Danach folgt immer der Identifier 17
    Danach das 6-stellige Ablaufdatum; Format YYMMDD
    Danach folgt immer der Identifier 21
    Danach die 10-stellige Seriennummer des OP-Sets
    Danach folgt immer der Identifier 10
    Danach die 8-stellige Chargennummer des Sterilisators (vorne mit Nullen aufgefüllt)
  */
  EANBarcode = CHAR(210) + CHAR(207) +
    N'010' + 
    RIGHT(N'0000000000000' + RTRIM(CAST(OpSetArtikel.EAN AS nchar)), 13) + 
    CHAR(207) + N'17' + 
    dbo.StrZero(YEAR(OpEtiKo.VerfallDatum), 2) + 
    dbo.StrZero(MONTH(OpEtiKo.VerfallDatum), 2) + 
    dbo.StrZero(dbo.DayOfMonth(OpEtiKo.VerfallDatum), 2) + 
    CHAR(207) + N'21' +
    RIGHT(N'0000000000' + RTRIM(CAST([OPETINR] AS nchar)), 10) +  
    CHAR(207) + N'10' + 
    RIGHT(N'00000000' + RTRIM(CAST(OPCharge.ChargeNr AS nchar)), 8),
  /*
    Und jetzt noch einmal in Klarschrift, aber mit in Klammern
    eingefasste Identifier
  */
  EANBcKlartext = N'(01)0' +
    RIGHT(N'0000000000000' + RTRIM(CAST(OpSetArtikel.EAN AS nchar)), 13) + 
    N'(17)' + 
    dbo.StrZero(YEAR(OpEtiKo.VerfallDatum), 2) + 
    dbo.StrZero(MONTH(OpEtiKo.VerfallDatum), 2) + 
    dbo.StrZero(dbo.DayOfMonth(OpEtiKo.VerfallDatum), 2) + 
    N'(21)' +
    RIGHT(N'0000000000' + RTRIM(CAST([OPETINR] AS nchar)), 10) +  
    N'(10)' +
    RIGHT(N'00000000' + RTRIM(CAST(OPCharge.ChargeNr AS nchar)), 8),
  OpEtiKo.EtiNr AS OpEtiNr, 
  OpEtiKo.Verfalldatum AS VerfallDatum, 
  OpSetArtikel.ArtikelNr AS OPEtiArtikelNr,
  LEFT(ArtGru.Gruppe, 2) AS OPEtiArtGru,
  N'[OPARTIKELBEZSP1]' AS OPEtiArtikelBez, 
  /*
    Für 3 italienische Kunden mit Kundenummer 293876, 293882, 293884 
    Hier muss in Zeile 2 die italienisiche OP-Setbez. angedruckt werden
    Ansonsten bleibt die 2. Zeile für die zus. OP-Setbez. leer
  */
  IIF(Kunden.KdNr IN (293876, 293882, 293884, 227500), OpSetArtikel.ArtikelBez6, OpSetArtikel.ArtikelBez) AS OPEtiArtikelBez2, 
  '[OPTEILARTIKELBEZSP1]' AS OPTeilArtikelBez,
  '[OPTEILMENGE]' AS OPTeilMenge,
  IsSiSSet = (
      SELECT CAST(IIF(COUNT(IOPEtiKo.ID) > 0, 1, 0) AS bit)
      FROM OPEtiPo
      JOIN OPEtiKo ON OPEtiPo.OPEtiKoID = OPEtiKo.ID
      JOIN EinzTeil ON OPEtiPo.EinzTeilID = EinzTeil.ID
      JOIN OPEtiKo AS IOPEtiKo ON EinzTeil.Code = IOPEtiKo.EtiNr
      WHERE OPEtiKo.EtiNr = N'[OPETINR]'
    )
FROM OpEtiKo, OpCharge, Artikel OpSetArtikel, ArtGru, Vsa, Kunden, (
  SELECT COUNT(OpSets.ID) AnzPos
  FROM OPSets, OpEtiko
  WHERE OpSets.ArtikelID = OpEtiKo.ArtikelID
  AND OpEtiKo.EtiNr = N'[OPETINR]'
) OPStueckliste 
WHERE OpEtiKo.OpChargeID = OpCharge.ID 
  AND OpEtiKo.ArtikelID = OpSetArtikel.ID 
  AND OPSetArtikel.ArtGruID = ArtGru.ID 
  AND OpEtiKo.PackVsaID = Vsa.ID 
  AND Vsa.KundenID = Kunden.ID 
  AND OpEtiKo.EtiNr = N'[OPETINR]';