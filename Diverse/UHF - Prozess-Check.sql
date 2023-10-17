WITH VsaAnfStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VSAANF'
)
SELECT Kunden.KdNr,
  Vsa.VsaNr,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  VsaAnfStatus.StatusBez AS [Status AnfArti],
  VsaAnf.Bestand AS Vertragsbestand,
  VsaAnf.BestandIst AS [Ist-Bestand live],
  VsaAnf.VomIstBestandErsatz AS [Anzahl Ersatz],
  [Ist-Bestand Testmandant] = (
    SELECT TVsaAnf.BestandIst
    FROM Salesianer_Test.dbo.VsaAnf AS TVsaAnf
    WHERE TVsaAnf.ID = VsaAnf.ID
  ),
  [Anzahl Teile live] = (
    SELECT COUNT(EinzTeil.ID)
    FROM EinzTeil
    WHERE EinzTeil.VsaID = Vsa.ID
      AND EinzTeil.ArtikelID = Artikel.ID
      AND EinzTeil.Status != N'Z'
      AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154)
  ), 
  [Anzahl Teile Testmandant] = (
    SELECT COUNT(EinzTeil.ID)
    FROM Salesianer_Test.dbo.EinzTeil
    WHERE EinzTeil.VsaID = Vsa.ID
      AND EinzTeil.ArtikelID = Artikel.ID
      AND EinzTeil.Status != N'Z'
      AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154)
  ),
  [Anzahl Teile zuletzt heute gescannt] = (
    SELECT COUNT(EinzTeil.ID)
    FROM EinzTeil
    WHERE EinzTeil.ID IN (
      SELECT TEinzTeil.ID
      FROM Salesianer_Test.dbo.EinzTeil AS TEinzTeil
      WHERE TEinzTeil.VsaID = Vsa.ID
        AND TEinzTeil.ArtikelID = Artikel.ID
        AND TEinzTeil.Status != N'Z'
        AND TEinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 137, 154)
    )
    AND EinzTeil.LastScanTime > DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)
  )
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN VsaAnfStatus ON VsaAnf.Status = VsaAnfStatus.Status
WHERE Kunden.KdNr = 10001826
  AND Vsa.VsaNr = 18
  --AND Artikel.ArtikelNr = N'110620010001'

GO