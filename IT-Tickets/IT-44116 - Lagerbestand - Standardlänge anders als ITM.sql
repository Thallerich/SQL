select Lagerart.Lagerart, Artikel.ArtikelNr, ArtGroe.Groesse, SUM(Bestand.Bestand) Bestand
from ArtGroe, Artikel, ITM_SMRO.[SAL\POLLNS]._BkStandardlaengen ro, Bestand, Lagerart, GroePo
where ArtGroe.ArtikelID = Artikel.ID
and Artikel.ArtikelNr = ro.ArtikelNr collate Latin1_General_CI_AS
and ArtGroe.Groesse = ro.GroesseLen collate Latin1_General_CI_AS
and ArtGroe.StandardLaenge = 0
and ArtGroe.Status = 'A'
and Artikel.Status = 'A'
and ArtGroe.Umlauf > 0
and Bestand.ArtGroeID = ArtGroe.ID
and Bestand.LagerArtID = LagerArt.ID
AND GroePo.Groesse = ArtGroe.Groesse AND GroePo.GroeKoID = Artikel.GroeKoID
and (LagerArt.LagerArt like 'ORAD%' OR Lagerart.Lagerart LIKE N'BUKA%')
group by Artikel.ArtikelNr, ArtGroe.Groesse, Lagerart.LagerArt, GroePo.Folge
having sum(Bestand.Bestand) > 0
ORDER BY Lagerart, ArtikelNr, GroePo.Folge;