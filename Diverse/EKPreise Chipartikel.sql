SELECT Artikel.ID AS ArtikelID, Artikel.ArtikelNr, Artikel.ArtikelNr2 AS BMDNr, Artikel.ArtikelBez$LAN$, Artikel.Packmenge, Me.MeBez$LAN$ AS Mengeneinheit, Artikel.EKPreis AS EKAdvanTex, EKPreis.Nr, EKPreis.Bezeichung, EKPreis.Eh, EKPreis.Faktor, EKPreis.[akt. Preis] AS EKPreisListe, IIF(Artikel.EKPreis > EKPreis.[akt. Preis], Artikel.EKPreis, EKPreis.[akt. Preis]) AS EKNeu
FROM __ekpreis AS EKPreis, Artikel, ME
WHERE Artikel.MEID = ME.ID
  AND EKPreis.Nr = Artikel.ArtikelNr2
  AND Artikel.BereichID IN (SELECT ID FROM Bereich WHERE Bereich IN ('SH', 'TW', 'IK'))
  AND Artikel.EAN IS NOT NULL
ORDER BY BMDNr;