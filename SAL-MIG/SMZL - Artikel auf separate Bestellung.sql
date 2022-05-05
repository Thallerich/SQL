DECLARE @BPoID int = 541562;

DECLARE @NewBKo TABLE (
  BKoID int
);

INSERT INTO BKo (BestNr, [Status], Name1, Name2, Strasse, Land, PLZ, Ort, AdressBlock, BKoArtID, LiefID, Datum, Memo, MemoIntern, LagerArtID ,LagerID, BestDat, FreigabeZeitpkt)
OUTPUT inserted.ID
INTO @NewBKo (BKoID)
SELECT NEXT VALUE FOR [NextID_ATBESTNR], N'F', Name1, Name2, Strasse, Land, PLZ, Ort, AdressBlock, BKoArtID, LiefID, Datum, Memo, MemoIntern, LagerArtID, LagerID, BestDat, FreigabeZeitpkt
FROM BKo
WHERE BKo.ID = (SELECT BPo.BKoID FROM BPo WHERE BPo.ID = @BPoID);

UPDATE BPo SET BPo.BKoID = (SELECT BKoID FROM @NewBKo)
WHERE BPo.ID = @BPoID;

SELECT BKo.BestNr FROM BKo WHERE ID = (SELECT BkoID FROM @NewBKo);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* Lagerart ändern und Dummy-AB anlegen                                                                                            */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */