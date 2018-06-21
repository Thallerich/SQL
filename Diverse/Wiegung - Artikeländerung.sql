DECLARE @KdNr int = 19009;
DECLARE @DatumVon date = N'2018-06-01';
DECLARE @DatumBis date = N'2018-06-05';
DECLARE @W_KGArtikel nchar(15) = N'104490000000';
DECLARE @W_EWArtikel nchar(15) = N'192620000000';
DECLARE @User nchar(4) = N'STHA';

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Beim Kunden @KdNr wird der falsch gewogene Artikel @W_EWArtikel durch den korrekten Artikel @W_KGArtikel ersetzt!         ++ */
/* ++   Artikel muss sowohl in der Lieferschein-Positions (LsPo) als auch Wareneingangs-Position (EPo) ersetzt werden!          ++ */
/* ++                                                                                                                           ++ */
/* ++ ACHTUNG: Skript funktioniert nicht für Lieferscheine, auf denen beide Artikel vorhanden sind - diese sind explizit        ++ */
/* ++          ausgenommen und müssen separat behandelt werden!                                                                 ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-06-21                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @W_Table TABLE (
  WiegungID int,
  EPoID int,
  LsPoID int,
  LsKoID int
);

DECLARE @W_KG_KdArtiID int = (SELECT KdArti.ID FROM KdArti, Kunden, Artikel WHERE KdArti.KundenID = Kunden.ID AND KdArti.ArtikelID = Artikel.ID AND Kunden.KdNr = @KdNr AND Artikel.ArtikelNr = @W_KGArtikel);
DECLARE @W_EW_KdArtiID int = (SELECT KdArti.ID FROM KdArti, Kunden, Artikel WHERE KdArti.KundenID = Kunden.ID AND KdArti.ArtikelID = Artikel.ID AND Kunden.KdNr = @KdNr AND Artikel.ArtikelNr = @W_EWArtikel);
DECLARE @UserID int = (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = @User);

INSERT INTO @W_Table
SELECT Wiegung.ID AS WiegungID, Wiegung.EPoID, LsPo.ID AS LsPoID, LsKo.ID AS LsKoID
FROM Wiegung
JOIN Vsa ON Wiegung.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN LsPo ON Wiegung.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN EPo ON Wiegung.EPoID = EPo.ID
JOIN EKo ON EPo.EKoID = EKo.ID
WHERE Kunden.KdNr = @KdNr
  AND EKo.Datum BETWEEN @DatumVon AND @DatumBis
  AND LsPo.KdArtiID = @W_EW_KdArtiID
  AND NOT EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.KdArtiID = @W_KG_KdArtiID
  );

UPDATE LsPo SET KdArtiID = @W_KG_KdArtiID
WHERE ID IN (
  SELECT DISTINCT LsPoID
  FROM @W_Table
);

UPDATE EPo SET KdArtiID = @W_KG_KdArtiID
WHERE ID IN (
  SELECT DISTINCT EPoID
  FROM @W_Table
);

UPDATE LsKo SET AenderMitarbeiID = @UserID, MemoIntern = ISNULL(MemoIntern, N'') + char(13) + char(10) + RTRIM(@User) + N': Kilogramm-Artikel wurde per Skript korrigiert - ' + RTRIM(@W_EWArtikel) + N' --> ' + RTRIM(@W_KGArtikel)
WHERE LsKo.ID IN (
  SELECT DISTINCT LsKoID
  FROM @W_Table
);