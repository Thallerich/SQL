/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Mapping-Tabelle - IDs füllen                                                                                              ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
BEGIN TRANSACTION;

  update __ArtikelMapping set ArtikelIDNeu = Artikel.ID
  from Artikel
  where __ArtikelMapping.ArtikelNrNeu = Artikel.ArtikelNr;

  update __ArtikelMapping set ArtikelIDAlt = Artikel.ID
  from Artikel
  where __ArtikelMapping.ArtikelNrAlt = Artikel.ArtikelNr;

COMMIT;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ 1. Teile auf einer Entnahmeliste zur�ck auf erfasst (Modulaufruf ZurueckAufErfasst)                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

if Object_ID('_Teile_ZurueckAufErfasst') is not null
  drop table _Teile_ZurueckAufErfasst;

select ('ZURUECKAUFERFASST;' + Teile.Barcode) ZurueckAufErfasst, Teile.*, __ArtikelMapping.*
into _Teile_ZurueckAufErfasst
from Teile, __ArtikelMapping
where Teile.ArtikelID = __ArtikelMapping.ArtikelIDAlt
and Teile.Status < 'L' /*entnommen*/
and Teile.Status <> '5' /*storniert*/;

select ZurueckAufErfasst
from _Teile_ZurueckAufErfasst;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ 2. Lagerteile - Artikelgrößen ändern                                                                                      ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

if Object_ID('_TeileLag_ArtikelundGroesse_aendern') is not null
  drop table _TeileLag_ArtikelundGroesse_aendern;

select TeileLag.*, __ArtikelMapping.*, ArtGroe.Groesse, -1 ArtGroeIDNeu, -1 BestandID
into _TeileLag_ArtikelundGroesse_aendern
from TeileLag, __ArtikelMapping, ArtGroe
where TeileLag.ArtGroeID = ArtGroe.ID
and ArtGroe.ArtikelID = __ArtikelMapping.ArtikelIDAlt
and TeileLag.Status in ('L','R');

update _TeileLag_ArtikelundGroesse_aendern set ArtGroeIDNeu = ArtGroe.ID
from ArtGroe
where ArtGroe.ArtikelID = _TeileLag_ArtikelundGroesse_aendern.ArtikelIDNeu
and ArtGroe.Groesse = _TeileLag_ArtikelundGroesse_aendern.Groesse;

update _TeileLag_ArtikelundGroesse_aendern set BestandID = Bestand.ID
from Bestand
where Bestand.ArtGroeID = _TeileLag_ArtikelundGroesse_aendern.ArtGroeID
and Bestand.LagerArtID = _TeileLag_ArtikelundGroesse_aendern.LagerArtID;

if Object_ID('Error_0001_fehlende_Groesse_bei_neuem_Artikel') is not null
  drop table Error_0001_fehlende_Groesse_bei_neuem_Artikel;

select Barcode, Groesse 
into _Error_0001_fehlende_Groesse_bei_neuem_Artikel
from _TeileLag_ArtikelundGroesse_aendern where ArtGroeIDNeu = -1;

select 'CHANGELAGERTEILARTGROE;' + rtrim(cast(t.ID as char)) + ';' + rtrim(cast(t.ArtGroeIDNeu as char)) + ';14' /*Wechsel der LagerArt oder Artikelgr��e*/
from _TeileLag_ArtikelundGroesse_aendern t
where t.ArtGroeIDNeu > -1;

SELECT * FROM _Error_0001_fehlende_Groesse_bei_neuem_Artikel;

GO

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ 3. Teile im Umlauf auf neuen Artikel (Skript 15 - Neue Kundenartikel per Mapping anlegen                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ 4. Teile neu buchen (Aufträge zurück auf erfasst und Modulaufruf AUFTRAGCLOSE)                                            ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

update Auftrag set Status = 'F' where ID in (
select StartAuftragID
from _Teile_ZurueckAufErfasst
where StartAuftragID > -1);

select distinct 'AUFTRAGCLOSE;' + rtrim(cast(StartAuftragID as char))
from _Teile_ZurueckAufErfasst
where StartAuftragID > -1;

select 'ERNEUTBUCHEN;' + barcode
from _Teile_ZurueckAufErfasst
where StartAuftragID = -1;

GO