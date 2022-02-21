DECLARE @PoolWearer TABLE (
  KdNr int,
  VsaNr int,
  Traeger nchar(10) COLLATE Latin1_General_CS_AS
);

INSERT INTO @PoolWearer
VALUES (272295, 22, N'0008'), (272295, 22, N'0009'), (272295, 112, N'0029'), (272295, 143, N'0009'), (272295, 167, N'0009'), (272295, 190, N'0001A'), (272295, 190, N'0001B'), (272295, 190, N'0001C'), (272295, 248, N'0017'), (272295, 263, N'0010'), (272295, 269, N'0001'), (272295, 283, N'0006'), (272295, 292, N'0001'), (272295, 299, N'0002'), (272295, 336, N'0027'), (272295, 336, N'0030'), (272295, 349, N'0030'), (272295, 362, N'0001'), (272295, 370, N'0005');

WITH Teilestatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'TEILE'
)
SELECT Teile.Barcode, Teilestatus.StatusBez AS [Status des Teils], Traeger.Traeger AS TrägerNr, Traeger.Nachname, Traeger.Vorname, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Teile.Eingang1 AS [letzter Eingang Produktion], Teile.Ausgang1 AS [letzter Ausgang Produktion], fRW.BasisAfa AS [Basis-Restwert], fRW.AlterInfo AS [Alter in Wochen], fRW.RestwertInfo AS [Restwert aktuell]
FROM Teile
CROSS APPLY funcGetRestwert(Teile.ID, N'2022/08', 1) AS fRW
JOIN Teilestatus ON Teile.Status = Teilestatus.[Status]
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN @PoolWearer AS PoolWearer ON PoolWearer.KdNr = Kunden.KdNr AND PoolWearer.VsaNr = Vsa.VsaNr AND PoolWearer.Traeger = Traeger.Traeger
WHERE Teile.Status BETWEEN N'N' AND N'W'
  AND ((Teile.Status = N'W' AND Teile.Einzug IS NULL) OR Teile.Status != N'W');

GO