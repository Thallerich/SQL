WITH AnfStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VSAANF'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, KdArti.Variante, AnfStatus.StatusBez AS [Status aktuell], [letzte Statusänderung] = STUFF((
    SELECT CHAR(10) + FORMAT(ChgLog.[Timestamp], N'dd.MM.yyyy HH:mm:ss') + N' - Statusänderung von ''' + AnfStatusOld.StatusBez + N''' auf ''' + AnfStatusNew.StatusBez + N''' durch Benutzer: ' + Mitarbei.Name
    FROM ChgLog
    JOIN Mitarbei ON ChgLog.MitarbeiID = Mitarbei.ID
    JOIN AnfStatus AS AnfStatusOld ON ChgLog.OldValue = AnfStatusOld.[Status]
    JOIN AnfStatus AS AnfStatusNew ON ChgLog.NewValue = AnfStatusNew.[Status]
    WHERE ChgLog.TableID = VsaAnf.ID
      AND ChgLog.TableName = N'VSAANF'
      AND ChgLog.FieldName = N'Status'
    ORDER BY ChgLog.[Timestamp] DESC
    FOR XML PATH (N'')
  ), 1, 1, N'')
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN AnfStatus ON VsaAnf.[Status] = AnfStatus.[Status]
WHERE Kunden.KdNr = 260092
  AND Vsa.VsaNr = 13
  AND Artikel.ArtikelNr = N'P9M1';