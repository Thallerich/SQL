/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Header                                                                                                          ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-09-25                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Kunden.ID AS KundenID, Kunden.KdNr, Firma.ID AS FirmaID, Firma.SuchCode AS FirmaKurz, Firma.FirmenBez, Firma.Strasse AS FirmaStrasse, Firma.Land AS FirmaLand, Firma.PLZ AS FirmaPLZ, Firma.Ort AS FirmaOrt
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE Kunden.ID = $ID$;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Preisliste                                                                                                      ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-09-25                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
DECLARE @NK int = 2;

SELECT DISTINCT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.ID AS KundenID, Artikel.ArtikelBez AS Artikelbezeichnung, IIF(WaschPrg.ChemReinigung = 1, N'chem.', N'') AS Variante, KdArti.WaschPreis AS NettoPreis, MwStZeit.MWStFaktor, KdBer.RabattWasch, ROUND((KdArti.WaschPreis - (KdArti.WaschPreis / 100 * KdBer.RabattWasch)) * (1 + MwStZeit.MWStFaktor), @NK) AS BruttoPreisRabattiert, @NK AS Nachkomma
FROM Traeger
JOIN BewKdAr ON Traeger.BewAbrID = BewKdAr.BewAbrID
JOIN KdArti ON BewKdAr.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN WaschPrg ON Artikel.WaschPrgID = WaschPrg.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN MwSt ON Kunden.MWStID = MwSt.ID
JOIN MwStZeit ON MwStZeit.MwStID = MwSt.ID AND GETDATE() BETWEEN MwStZeit.VonDatum AND MwStZeit.BisDatum
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
WHERE BewKdAr.ProzTraeger = 100
  AND BewKdAr.Vorlaeufig = 0
  AND Kunden.ID = $ID$
ORDER BY KdNr, Artikelbezeichnung;