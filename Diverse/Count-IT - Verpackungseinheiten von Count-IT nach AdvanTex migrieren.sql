SELECT PackageUnit.PackageUnitID, PackageUnit.CreationDate, PackageUnit.LocationID, PackageUnit.EanPackagingUnit AS Menge, Chip.Sgtin96HexCode, Chip.ArticleID
FROM CustomerSystem.dbo.PackageUnit
JOIN CustomerSystem.dbo.Chip ON Chip.PackageUnitID = PackageUnit.PackageUnitID
WHERE PackageUnit.CreationDate > N'2024-01-01 00:00:00.000';

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ VPSKO / VPSPO - Datensätze erstellen                                                                                      ++ */
/* ++ EinzHist.LastVPSPoID setzen                                                                                               ++ */
/* ++ Scan schreiben (Beispiel Scan.ID = 2834792063)                                                                            ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2024-09-02                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */