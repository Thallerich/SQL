ALTER VIEW [sapbw].[V_BW_LIEFERQUOTE] AS
  SELECT Vsa.VsaNr,
          Kunden.KdNr,
          AnfKo.[Status],
          AnfKo.LieferDatum AS AnfDatum,
          AnfKo.AuftragsNr,
          SUM(IIF(DATEDIFF(minute, AnfPo.Anlage_, AnfPo.BestaetZeitpunkt) < 1, 0, AnfPo.Angefordert)) AS Angefordert,
          UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)) AS ArtikelNr,
          Artikel.ArtikelNr AS Artikelbasis,
          ArtGroe.Groesse,
          IIF(ME.IsoCode = N'-', N'ST', ME.IsoCode) AS Mengeneinheit,
          Bereich.Bereich,
          IIF(LsKo.ID = -1, NULL, LsKo.LsNr) AS LsNr,
          LsKo.Datum AS LSDatum,
          SUM(ISNULL(LsPo.Menge, 0)) AS LSMenge
  FROM Salesianer.dbo.AnfPo
  JOIN Salesianer.dbo.AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  JOIN Salesianer.dbo.ArtGroe ON AnfPo.ArtGroeID = ArtGroe.ID
  JOIN Salesianer.dbo.Vsa ON AnfKo.VsaID = Vsa.ID
  JOIN Salesianer.dbo.Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Salesianer.dbo.KdArti ON AnfPo.KdArtiID = KdArti.ID
  JOIN Salesianer.dbo.Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Salesianer.dbo.ME ON Artikel.MEID = ME.ID
  JOIN Salesianer.dbo.KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN Salesianer.dbo.Bereich ON KdBer.BereichID = Bereich.ID
  JOIN Salesianer.dbo.LsKo ON AnfKo.LsKoID = LsKo.ID
  LEFT JOIN Salesianer.dbo.LsPo ON LsPo.LsKoID = LsKo.ID AND AnfPo.KdArtiID = LsPo.KdArtiID AND AnfPo.ArtGroeID = LsPo.ArtGroeID
  WHERE AnfPo.Angefordert > 0
    AND AnfPo.Geliefert > 0
    AND AnfKo.Lieferdatum >= DATEADD(day, -10, CAST(GETDATE() AS date))
  GROUP BY Vsa.VsaNr, Kunden.KdNr, AnfKo.[Status], AnfKo.LieferDatum, AnfKo.AuftragsNr, UPPER(Artikel.ArtikelNr + IIF(ISNULL(ArtGroe.Groesse, N'-') = N'-', N'', N'-' + ArtGroe.Groesse)), Artikel.ArtikelNr, ArtGroe.Groesse, IIF(ME.IsoCode = N'-', N'ST', ME.IsoCode), Bereich.Bereich, IIF(LsKo.ID = -1, NULL, LsKo.LsNr), LsKo.Datum;

GO