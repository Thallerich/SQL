/*******************************************************************************************************************************
**                                                                                                                            **
** FIBU-Export zu ITM - erstellt von Stefan Thaller, Wozabal Miettex GmbH, 10.04.2018, Version 1.0                            **
** laut Schnittstellenbeschreibung: Doku_Schnittstelle-ITM-SAP_SMRO.xls                                                       **
**                                                                                                                            **
** ACHTUNG: Alle Felder haben vorgegeben Längen - bei Änderungen am Skript beachten, dass diese gleich bleiben!               **
**                                                                                                                            **
*******************************************************************************************************************************/

DECLARE @OrderByAutoInc int;
DECLARE @KopfPos nchar(1);
DECLARE @Art nchar(1);
DECLARE @Belegdat date;
DECLARE @WaeCode nchar(4);
DECLARE @BelegNr int;
DECLARE @Nettowert money;
DECLARE @Bruttowert money;
DECLARE @Steuerschl nchar(2);
DECLARE @Debitor nchar(24);
DECLARE @Gegenkonto nchar(17);
DECLARE @Kostenstelle nchar(10);
DECLARE @ZahlZiel nchar(4);
DECLARE @BasisRechnung nchar(10);
DECLARE @ProduktionFibuNr nchar(4);
DECLARE @DetailNetto money;

DECLARE @i int = 0;

DECLARE @output TABLE ([Order] int, exportline nvarchar(max));

DECLARE fibuexp CURSOR LOCAL FAST_FORWARD FOR
  SELECT MAX(Export.OrderByAutoInc) AS OrderByAutoInc, Export.KopfPos, Export.Art, Export.Belegdat, Export.WaeCode, Export.BelegNr, Export.Nettowert, Export.Bruttowert, Export.Steuerschl, Export.Debitor, Export.Gegenkonto, Export.Kostenstelle, Export.ZahlZiel, IIF(RechKo.BasisRechKoID > 0 AND RechKo.Art = N'G', CAST(BasisRechKo.RechNr AS nchar(10)), NULL) AS BasisRechnung, CAST(CAST(Export.ProduktionFibuNr AS int) AS nchar(4)) AS ProduktionFibuNr, SUM(Export.DetailNetto)
  FROM #bookingexport AS Export
  JOIN RechKo ON Export.RechKoID = RechKo.ID
  JOIN RechKo AS BasisRechKo ON RechKo.BasisRechKoID = BasisRechKo.ID
  GROUP BY Export.KopfPos, Export.Art, Export.Belegdat, Export.WaeCode, Export.BelegNr, Export.Nettowert, Export.Bruttowert, Export.Steuerschl, Export.Debitor, Export.Gegenkonto, Export.Kostenstelle, Export.ZahlZiel, IIF(RechKo.BasisRechKoID > 0 AND RechKo.Art = N'G', CAST(BasisRechKo.RechNr AS nchar(10)), NULL), CAST(CAST(Export.ProduktionFibuNr AS int) AS nchar(4))
  ORDER BY OrderByAutoInc ASC;

-- BGR00 - Belegkopf für Buchhaltungsbeleg
INSERT INTO @output
SELECT @i AS [Order],
  N'0' +                                                  --f_m_stype
    N'FAKTURA     ' +                                     --f_group
    N'100' +                                              --f_mandt
    N'SAITM       ' +                                     --f_usnam
    N'        ' +                                         --f_start
    N'X' +                                                --f_xkeep
    N'/'                                                  --nodata
  AS exportline;

SET @i = @i + 1;

OPEN fibuexp;

FETCH NEXT FROM fibuexp INTO @OrderByAutoInc, @KopfPos, @Art, @Belegdat, @WaeCode, @BelegNr, @Nettowert, @Bruttowert, @Steuerschl, @Debitor, @Gegenkonto, @Kostenstelle, @ZahlZiel, @BasisRechnung, @ProduktionFibuNr, @DetailNetto;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @KopfPos = N'K'
  BEGIN
    
    --BBKPF - Belegkopf für Buchhaltungsbeleg
    INSERT INTO @output 
    SELECT @i AS [Order],
      N'1' +                                                                --fk_stype
        N'FB01                ' +                                           --fk_tcode
        FORMAT(@Belegdat, 'ddMMyyyy', 'de-AT') +                            --fk_bldat
        IIF(@Art = N'R', N'AR', N'GU') +                                    --fk_blart
        N'1250' +                                                           --fk_bukrs
        FORMAT(@Belegdat, 'ddMMyyyy', 'de-AT') +                            --fk_budat
        N'/ ' +                                                             --fk_monat
        CAST(@WaeCode AS nchar(5)) +                                        --fK_waers
        N'/         ' +                                                     --fk_kursf
        CAST(@BelegNr AS nchar(10)) +                                       --fk_belnr
        N'/       ' +                                                       --fk_wwert
        IIF(@Art = N'R', N'AR', N'GU') + CAST(@BelegNr AS nchar(14)) +      --fk_xblnr
        N'/               ' +                                               --fk_bvorg
        N'/                        ' +                                      --fk_bktxt
        N'    ' +                                                           --fk_pargb
        N'/       ' +                                                       --fk_auglv
        N'/     ' +                                                         --fk_vbund
        N'X' +                                                              --fk_xmwst
        N'/         ' +                                                     --fk_docid
        N'/                                       ' +                       --fk_barcd
        N'/       ' +                                                       --fk_stodt
        N'/   ' +                                                           --fk_brnch
        N'/  ' +                                                            --fk_numpg
        N'/ ' +                                                             --fk_stgrd
        N'/         ' +                                                     --fk_kursf_m
        N'/                                                 ' +             --fk_augtx
        N'/' +                                                              --fk_xprfg
        N'/' +                                                              --fk_xbwae
        N'/   ' +                                                           --fk_ldgrp
        N'/            ' +                                                  --fk_propmano
        N'/'                                                                --fk_sende
      AS exportline;

      SET @i = @i + 1;

      -- BBSEG-KD - Belegkopf für Buchhaltungsbeleg - Kundenbuchung
      INSERT INTO @output
      SELECT @i AS [Order], 
        N'2' +                                                                      --fb_fbs_stype
          N'ZBSEG                         ' +                                       --fb_tbnam
          IIF(@Art = N'G', N'11', N'01') +                                          --fb_newbs
          N'/         ' +                                                           --fb_dummy
          N'/' +                                                                    --fb_newum
          N'/   ' +                                                                 --fb_newbk
          CAST(FORMAT(ABS(@Bruttowert), 'F2', 'de-AT') AS nchar(16)) +              --fb_wrbtr
          N'/               ' +                                                     --fb_dmbtr
          N'/               ' +                                                     --fb_wmwst
          N'/               ' +                                                     --fb_mwsts
          @Steuerschl +                                                             --fb_mwskz
          N'/' +                                                                    --fb_xskrl
          N'/               ' +                                                     --fb_fwzuz
          N'/               ' +                                                     --fb_hwzuz
          N'/   ' +                                                                 --fb_gsber
          N'/         ' +                                                           --fb_kostl
          N'/   ' +                                                                 --fb_dummy4
          N'/           ' +                                                         --fb_aufnr
          N'/         ' +                                                           --fb_ebeln
          N'/    ' +                                                                --fb_ebelp
          N'/               ' +                                                     --fb_projn
          N'/                 ' +                                                   --fb_matnr
          N'/   ' +                                                                 --fb_werks
          N'/                ' +                                                    --fb_menge
          N'/  ' +                                                                  --fb_meins
          N'/         ' +                                                           --fb_vbel2
          N'/     ' +                                                               --fb_posn2
          N'/   ' +                                                                 --fb_eten2
          N'/       ' +                                                             --fb_pernr
          N'/  ' +                                                                  --fb_bewar
          N'/       ' +                                                             --fb_valut
          FORMAT(@Belegdat, 'ddMMyyyy', 'de-AT') +                                  --fb_zfbdt
          N'/ ' +                                                                   --fb_zinkz
          N'                  ' +                                                   --fb_zuor
          N'/  ' +                                                                  --fb_fkont
          N'/' +                                                                    --fb_xaabg
          N'*                                                 ' +                   --fb_sgtxt
          N'/ ' +                                                                   --fb_blnkz
          N'/               ' +                                                     --fb_blnbt
          N'/       ' +                                                             --fb_blnpz
          N'/ ' +                                                                   --fb_maber
          N'/               ' +                                                     --fb_skfbt
          N'/               ' +                                                     --fb_wskto
          @ZahlZiel +                                                               --fb_zterm  
          N'/  ' +                                                                  --fb_zbd1t
          N'/     ' +                                                               --fb_zbd1p
          N'/  ' +                                                                  --fb_zbd2t
          N'/     ' +                                                               --fb_z2d2p
          N'/  ' +                                                                  --fb_zbd3t
          N'/' +                                                                    --fb_zlspr
          ISNULL(@BasisRechnung, CAST(N'' AS nchar(10))) +                          --fb_rebzg  
          N'/   ' +                                                                 --fb_rebzj
          N'/  ' +                                                                  --fb_rebzz
          N'/' +                                                                    --fb_zlsch
          N'/       ' +                                                             --fb_samnr
          N'/' +                                                                    --fb_zbfix
          N'/ ' +                                                                   --fb_qsskz
          N'/               ' +                                                     --fb_qsshb
          N'/               ' +                                                     --fb_qsfbt
          N'/          ' +                                                          --fb_esrnr
          N'/ ' +                                                                   --fb_esrpz
          N'/                          ' +                                          --fb_esrre
          N'/       ' +                                                             --fb_fdtag
          N'/ ' +                                                                   --fb_dflev
          N'/           ' +                                                         --fb_anln1
          N'/   ' +                                                                 --fb_anln2
          N'/       ' +                                                             --fb_bzdat
          N'/  ' +                                                                  --fb_anbwa
          N'/      ' +                                                              --fb_abper
          N'/               ' +                                                     --fb_gbetr
          N'/         ' +                                                           --fb_kursr
          N'/' +                                                                    --fb_mansp
          N'/' +                                                                    --fb_mschl
          N'/    ' +                                                                --fb_hbkid
          N'/   ' +                                                                 --fb_bvtyp
          N'/         ' +                                                           --fb_anfbn
          N'/   ' +                                                                 --fb_anfbu
          N'/   ' +                                                                 --fb_anfbj
          N'/  ' +                                                                  --fb_lzbkz
          N'/  ' +                                                                  --fb_landl
          N'/' +                                                                    --fb_diekz
          N'/       ' +                                                             --fb_zolld
          N'/       ' +                                                             --fb_zollt
          N'/       ' +                                                             --fb_vrsdt
          N'/' +                                                                    --fb_vrskz
          N'/                 ' +                                                   --fb_hzuon
          N'/' +                                                                    --fb_regul
          N'/                                  ' +                                  --fb_name1
          N'/                                  ' +                                  --fb_name2
          N'/                                  ' +                                  --fb_name3
          N'/                                  ' +                                  --fb_name4
          N'/                                  ' +                                  --fb_stras
          N'/                                  ' +                                  --fb_ort01
          N'/         ' +                                                           --fb_pstlz
          N'/  ' +                                                                  --fb_land1
          N'/  ' +                                                                  --fb_regio
          N'/              ' +                                                      --fb_bankl
          N'/  ' +                                                                  --fb_banks
          N'/                 ' +                                                   --fb_bankn
          N'/ ' +                                                                   --fb_bkont
          N'/               ' +                                                     --fb_stcd1
          N'/          ' +                                                          --fb_stcd2
          N'/       ' +                                                             --fb_madat
          N'/' +                                                                    --fb_manst
          N'/  ' +                                                                  --fb_egmld
          N'/  ' +                                                                  --fb_dummy2
          N'/                   ' +                                                 --fb_stceg
          N'/' +                                                                    --fb_stkza
          N'/' +                                                                    --fb_stkzu
          N'/         ' +                                                           --fb_pfach
          N'/         ' +                                                           --fb_pstl2
          N'/' +                                                                    --fb_spras
          N'/' +                                                                    --fb_xinve
          LEFT(@Debitor, 17) +                                                      --fb_newko
          N'/  ' +                                                                  --fb_newbw
          N'/                ' +                                                    --fb_knrze
          N'/         ' +                                                           --fb_hkont
          N'/         ' +                                                           --fb_prctr
          N'/            ' +                                                        --fb_vertn
          N'/' +                                                                    --fb_vertt
          N'/   ' +                                                                 --fb_vbewa
          N'/               ' +                                                     --fb_hwbas
          N'/               ' +                                                     --fb_fwbas
          N'/             ' +                                                       --fb_fipos
          N'/     ' +                                                               --fb_vname
          N'/  ' +                                                                  --fb_egrup
          N'/ ' +                                                                   --fb_btype
          N'/         ' +                                                           --fb_paobjnr
          N'/           ' +                                                         --fb_kstgr
          N'/       ' +                                                             --fb_imkey
          N'/       ' +                                                             --fb_dummy3
          N'/         ' +                                                           --fb_vptnr
          N'/           ' +                                                         --fb_nplnr
          N'/   ' +                                                                 --fb_vornr
          N'/' +                                                                    --fb_xegdr
          N'/ ' +                                                                   --fb_recid
          N'/         ' +                                                           --fb_prrct
          N'/                       ' +                                             --fb_projk
          N'/ ' +                                                                   --fb_uzawe
          N'/              ' +                                                      --fb_txjcd
          N'/               ' +                                                     --fb_fistl
          N'/         ' +                                                           --fb_geber
          N'/               ' +                                                     --fb_dmbe2
          N'/               ' +                                                     --fb_dmbe3
          N'/   ' +                                                                 --fb_pargb
          N'/           ' +                                                         --fb_xref1
          N'/           ' +                                                         --fb_xref2
          N'/         ' +                                                           --fb_kblnr
          N'/  ' +                                                                  --fb_kblpos
          N'/       ' +                                                             --fb_wdate
          N'/' +                                                                    --fb_wgbkz
          N'/' +                                                                    --fb_xaktz
          N'/                             ' +                                       --fb_wname
          N'/                             ' +                                       --fb_wort1
          N'/                             ' +                                       --fb_wbzog
          N'/                             ' +                                       --fb_wort2
          N'/                                                           ' +         --fb_wbank
          N'/                                                           ' +         --fb_wlzbp
          N'/       ' +                                                             --fb_diskp
          N'/  ' +                                                                  --fb_diskt
          N'/               ' +                                                     --fb_winfw
          N'/               ' +                                                     --fb_winhw
          N'/' +                                                                    --fb_wevwv
          N'/' +                                                                    --fb_wstat
          N'/ ' +                                                                   --fb_wmwkz
          N'/' +                                                                    --fb_wstkz
          N'/                 ' +                                                   --fb_rke_artnr
          N'/ ' +                                                                   --fb_rke_bonus
          N'/   ' +                                                                 --fb_rke_brsch
          N'/   ' +                                                                 --fb_rke_burks
          N'/     ' +                                                               --fb_rke_bzrik
          N'/    ' +                                                                --fb_rke_eform
          N'/   ' +                                                                 --fb_rke_fkart
          N'/   ' +                                                                 --fb_rke_gebie
          N'/   ' +                                                                 --fb_rke_gsber
          N'/         ' +                                                           --fb_rke_kaufn
          N'/ ' +                                                                   --fb_rke_kdgrp
          N'/     ' +                                                               --fb_rke_kdpos
          N'/         ' +                                                           --fb_rke_kndnr
          N'/   ' +                                                                 --fb_rke_kokrs
          N'/           ' +                                                         --fb_rke_kstrg
          N'/  ' +                                                                  --fb_rke_land1
          N'/' +                                                                    --fb_rke_maabc
          N'/        ' +                                                            --fb_rke_matkl
          N'/         ' +                                                           --fb_rke_prctr
          N'/                       ' +                                             --fb_rke_pspnr
          N'/           ' +                                                         --fb_rke_rkaufnr
          N'/ ' +                                                                   --fb_rke_spart
          N'/   ' +                                                                 --fb_rke_vkbur
          N'/  ' +                                                                  --fb_rke_vkgrp
          N'/   ' +                                                                 --fb_rke_vkorg
          N'/ ' +                                                                   --fb_rke_vtweg
          N'/   ' +                                                                 --fb_rke_werks
          N'/ ' +                                                                   --fb_rke_kmbrnd
          N'/ ' +                                                                   --fb_rke_kmcatg
          N'/         ' +                                                           --fb_rke_kmhi01
          N'/         ' +                                                           --fb_rke_kmhi02
          N'/         ' +                                                           --fb_rke_kmhi03
          N'/ ' +                                                                   --fb_rke_kmkdgr
          N'/  ' +                                                                  --fb_rke_kmland
          N'/        ' +                                                            --fb_rke_kmmakl
          N'/ ' +                                                                   --fb_rke_kmniel
          N'/ ' +                                                                   --fb_rke_kmstge
          N'/   ' +                                                                 --fb_rke_kmvkbu
          N'/  ' +                                                                  --fb_rke_kmvkgr
          N'/       ' +                                                             --fb_rke_kmvtnr
          N'/         ' +                                                           --fb_rke_pprctr
          N'/         ' +                                                           --fb_rke_copa_kostl
          N'/   ' +                                                                 --fb_rke_ww904
          N'/ ' +                                                                   --fb_rke_ww905
          N'/     ' +                                                               --fb_vbund
          N'/   ' +                                                                 --fb_fkber
          N'/       ' +                                                             --fb_dabrz
          N'/' +                                                                    --fb_xstba
          N'/  ' +                                                                  --fb_rstgr
          N'/                       ' +                                             --fb_fipex
          N'/' +                                                                    --fb_xnegp
          N'/ ' +                                                                   --fb_gricd
          N'/  ' +                                                                  --fb_grirg
          N'/ ' +                                                                   --fb_gityp
          N'/ ' +                                                                   --fb_fityp
          N'/ ' +                                                                   --fb_stcdt
          N'/' +                                                                    --fb_stkzn
          N'/                 ' +                                                   --fb_stcd3
          N'/                 ' +                                                   --fb_stcd4
          N'/                   ' +                                                 --fb_xref3
          N'/                             ' +                                       --fb_kidno
          N'/ ' +                                                                   --fb_dtws1
          N'/ ' +                                                                   --fb_dtws2
          N'/ ' +                                                                   --fb_dtws3
          N'/ ' +                                                                   --fb_dtws4
          N'/ ' +                                                                   --fb_dtaws
          N'/    ' +                                                                --fb_pycur
          N'/               ' +                                                     --fb_pyamt
          N'/   ' +                                                                 --fb_bupla
          N'/   ' +                                                                 --fb_secco
          N'/     ' +                                                               --fb_lstar
          N'/         ' +                                                           --fb_egdeb
          N'/       ' +                                                             --fb_wenr
          N'/       ' +                                                             --fb_genr
          N'/       ' +                                                             --fb_grnr
          N'/       ' +                                                             --fb_menr
          N'/            ' +                                                        --fb_mive
          N'/   ' +                                                                 --fb_nksl
          N'/    ' +                                                                --fb_empsl
          N'/            ' +                                                        --fb_svwnr
          N'/         ' +                                                           --fb_sberi
          N'/   ' +                                                                 --fb_kkber
          N'/         ' +                                                           --fb_empfb
          N'/         ' +                                                           --fb_kursr_m
          N'/         ' +                                                           --fb_j_1kfrepre
          N'/                             ' +                                       --fb_j_1kftbus
          N'/                             ' +                                       --fb_j_1kftind
          N'/    ' +                                                                --fb_idxsp
          N'/              ' +                                                      --fb_anred
          N'/            ' +                                                        --fb_recnnr
          N'/            ' +                                                        --fb_e_mive
          N'/                   ' +                                                 --fb_bkref
          N'/' +                                                                    --fb_dtams
          N'/ ' +                                                                   --fb_cession_kz
          N'/                   ' +                                                 --fb_grant_nbr
          N'/               ' +                                                     --fb_fkber_long
          N'/' +                                                                    --fb_erlkz
          N'/                                 ' +                                   --fb_iban
          N'/       ' +                                                             --fb_valid_from
          N'/         ' +                                                           --fb_segment
          N'/         ' +                                                           --fb_psegment
          N'/    ' +                                                                --fb_hktid
          N'/' +                                                                    --fb_xsiwe
          N'/' +                                                                    --fb_sende
          N'/       '                                                               --fb_prodper
      AS exportline;

      SET @i = @i + 1;
  END;

  IF @KopfPos = N'S'
  BEGIN
      -- BBESG-ERLKTO - Belegkopf für Buchhaltungsbeleg - Erlöskontobuchung
      INSERT INTO @output
      SELECT @i AS [Order], 
        N'2' +                                                                --fb_fbs_stype
          N'ZBSEG                         ' +                                 --fb_tbnam
          IIF(@Art = N'G', N'40', N'50') +                                    --fb_newbs
          N'/         ' +                                                     --fb_dummy
          N'/' +                                                              --fb_newum
          N'/   ' +                                                           --fb_newbk
          CAST(FORMAT(ABS(@DetailNetto * 1.2), 'F2', 'de-AT') AS nchar(16)) + --fb_wrbtr
          N'/               ' +                                               --fb_dmbtr
          N'/               ' +                                               --fb_wmwst
          N'/               ' +                                               --fb_mwsts
          N'/ ' +                                                             --fb_mwskz
          N'/' +                                                              --fb_xskrl
          N'/               ' +                                               --fb_fwzuz
          N'/               ' +                                               --fb_hwzuz
          N'/   ' +                                                           --fb_gsber
          RTRIM(@ProduktionFibuNr) + @Kostenstelle +                          --fb_kostl
          N'/   ' +                                                           --fb_dummy4
          N'/           ' +                                                   --fb_aufnr
          N'/         ' +                                                     --fb_ebeln
          N'/    ' +                                                          --fb_ebelp
          N'/               ' +                                               --fb_projn
          N'/                 ' +                                             --fb_matnr
          N'/   ' +                                                           --fb_werks
          N'/                ' +                                              --fb_menge
          N'/  ' +                                                            --fb_meins
          N'/         ' +                                                     --fb_vbel2
          N'/     ' +                                                         --fb_posn2
          N'/   ' +                                                           --fb_eten2
          N'/       ' +                                                       --fb_pernr
          N'/  ' +                                                            --fb_bewar
          N'/       ' +                                                       --fb_valut
          N'/       ' +                                                       --fb_zfbdt
          N'/ ' +                                                             --fb_zinkz
          LEFT(@Debitor, 18) +                                                --fb_zuor
          N'/  ' +                                                            --fb_fkont
          N'/' +                                                              --fb_xaabg
          N'+                                                 ' +             --fb_sgtxt
          N'/ ' +                                                             --fb_blnkz
          N'/               ' +                                               --fb_blnbt
          N'/       ' +                                                       --fb_blnpz
          N'/ ' +                                                             --fb_maber
          N'/               ' +                                               --fb_skfbt
          N'/               ' +                                               --fb_wskto
          N'/   ' +                                                           --fb_zterm
          N'/  ' +                                                            --fb_zbd1t
          N'/     ' +                                                         --fb_zbd1p
          N'/  ' +                                                            --fb_zbd2t
          N'/     ' +                                                         --fb_z2d2p
          N'/  ' +                                                            --fb_zbd3t
          N'/' +                                                              --fb_zlspr
          N'          ' +                                                     --fb_rebzg
          N'/   ' +                                                           --fb_rebzj
          N'/  ' +                                                            --fb_rebzz
          N'/' +                                                              --fb_zlsch
          N'/       ' +                                                       --fb_samnr
          N'/' +                                                              --fb_zbfix
          N'/ ' +                                                             --fb_qsskz
          N'/               ' +                                               --fb_qsshb
          N'/               ' +                                               --fb_qsfbt
          N'/          ' +                                                    --fb_esrnr
          N'/ ' +                                                             --fb_esrpz
          N'/                          ' +                                    --fb_esrre
          N'/       ' +                                                       --fb_fdtag
          N'/ ' +                                                             --fb_dflev
          N'/           ' +                                                   --fb_anln1
          N'/   ' +                                                           --fb_anln2
          N'/       ' +                                                       --fb_bzdat
          N'/  ' +                                                            --fb_anbwa
          N'/      ' +                                                        --fb_abper
          N'/               ' +                                               --fb_gbetr
          N'/         ' +                                                     --fb_kursr
          N'/' +                                                              --fb_mansp
          N'/' +                                                              --fb_mschl
          N'/    ' +                                                          --fb_hbkid
          N'/   ' +                                                           --fb_bvtyp
          N'/         ' +                                                     --fb_anfbn
          N'/   ' +                                                           --fb_anfbu
          N'/   ' +                                                           --fb_anfbj
          N'/  ' +                                                            --fb_lzbkz
          N'/  ' +                                                            --fb_landl
          N'/' +                                                              --fb_diekz
          N'/       ' +                                                       --fb_zolld
          N'/       ' +                                                       --fb_zollt
          N'/       ' +                                                       --fb_vrsdt
          N'/' +                                                              --fb_vrskz
          N'/                 ' +                                             --fb_hzuon
          N'/' +                                                              --fb_regul
          N'/                                  ' +                            --fb_name1
          N'/                                  ' +                            --fb_name2
          N'/                                  ' +                            --fb_name3
          N'/                                  ' +                            --fb_name4
          N'/                                  ' +                            --fb_stras
          N'/                                  ' +                            --fb_ort01
          N'/         ' +                                                     --fb_pstlz
          N'/  ' +                                                            --fb_land1
          N'/  ' +                                                            --fb_regio
          N'/              ' +                                                --fb_bankl
          N'/  ' +                                                            --fb_banks
          N'/                 ' +                                             --fb_bankn
          N'/ ' +                                                             --fb_bkont
          N'/               ' +                                               --fb_stcd1
          N'/          ' +                                                    --fb_stcd2
          N'/       ' +                                                       --fb_madat
          N'/' +                                                              --fb_manst
          N'/  ' +                                                            --fb_egmld
          N'/  ' +                                                            --fb_dummy2
          N'/                   ' +                                           --fb_stceg
          N'/' +                                                              --fb_stkza
          N'/' +                                                              --fb_stkzu
          N'/         ' +                                                     --fb_pfach
          N'/         ' +                                                     --fb_pstl2
          N'/' +                                                              --fb_spras
          N'/' +                                                              --fb_xinve
          @Gegenkonto +                                                       --fb_newko
          N'/  ' +                                                            --fb_newbw
          N'/                ' +                                              --fb_knrze
          N'/         ' +                                                     --fb_hkont
          N'/         ' +                                                     --fb_prctr
          N'/            ' +                                                  --fb_vertn
          N'/' +                                                              --fb_vertt
          N'/   ' +                                                           --fb_vbewa
          N'/               ' +                                               --fb_hwbas
          N'/               ' +                                               --fb_fwbas
          N'/             ' +                                                 --fb_fipos
          N'/     ' +                                                         --fb_vname
          N'/  ' +                                                            --fb_egrup
          N'/ ' +                                                             --fb_btype
          N'/         ' +                                                     --fb_paobjnr
          N'/           ' +                                                   --fb_kstgr
          N'/       ' +                                                       --fb_imkey
          N'/       ' +                                                       --fb_dummy3
          N'/         ' +                                                     --fb_vptnr
          N'/           ' +                                                   --fb_nplnr
          N'/   ' +                                                           --fb_vornr
          N'/' +                                                              --fb_xegdr
          N'/ ' +                                                             --fb_recid
          N'/         ' +                                                     --fb_prrct
          N'/                       ' +                                       --fb_projk
          N'/ ' +                                                             --fb_uzawe
          N'/              ' +                                                --fb_txjcd
          N'/               ' +                                               --fb_fistl
          N'/         ' +                                                     --fb_geber
          N'/               ' +                                               --fb_dmbe2
          N'/               ' +                                               --fb_dmbe3
          N'/   ' +                                                           --fb_pargb
          N'/           ' +                                                   --fb_xref1
          N'/           ' +                                                   --fb_xref2
          N'/         ' +                                                     --fb_kblnr
          N'/  ' +                                                            --fb_kblpos
          N'/       ' +                                                       --fb_wdate
          N'/' +                                                              --fb_wgbkz
          N'/' +                                                              --fb_xaktz
          N'/                             ' +                                 --fb_wname
          N'/                             ' +                                 --fb_wort1
          N'/                             ' +                                 --fb_wbzog
          N'/                             ' +                                 --fb_wort2
          N'/                                                           ' +   --fb_wbank
          N'/                                                           ' +   --fb_wlzbp
          N'/       ' +                                                       --fb_diskp
          N'/  ' +                                                            --fb_diskt
          N'/               ' +                                               --fb_winfw
          N'/               ' +                                               --fb_winhw
          N'/' +                                                              --fb_wevwv
          N'/' +                                                              --fb_wstat
          N'/ ' +                                                             --fb_wmwkz
          N'/' +                                                              --fb_wstkz
          N'/                 ' +                                             --fb_rke_artnr
          N'/ ' +                                                             --fb_rke_bonus
          N'/   ' +                                                           --fb_rke_brsch
          N'/   ' +                                                           --fb_rke_burks
          N'/     ' +                                                         --fb_rke_bzrik
          N'/    ' +                                                          --fb_rke_eform
          N'/   ' +                                                           --fb_rke_fkart
          N'/   ' +                                                           --fb_rke_gebie
          N'/   ' +                                                           --fb_rke_gsber
          N'/         ' +                                                     --fb_rke_kaufn
          N'/ ' +                                                             --fb_rke_kdgrp
          N'/     ' +                                                         --fb_rke_kdpos
          N'/         ' +                                                     --fb_rke_kndnr
          N'/   ' +                                                           --fb_rke_kokrs
          N'/           ' +                                                   --fb_rke_kstrg
          N'/  ' +                                                            --fb_rke_land1
          N'/' +                                                              --fb_rke_maabc
          N'/        ' +                                                      --fb_rke_matkl
          N'/         ' +                                                     --fb_rke_prctr
          N'/                       ' +                                       --fb_rke_pspnr
          N'/           ' +                                                   --fb_rke_rkaufnr
          N'/ ' +                                                             --fb_rke_spart
          N'/   ' +                                                           --fb_rke_vkbur
          N'/  ' +                                                            --fb_rke_vkgrp
          N'/   ' +                                                           --fb_rke_vkorg
          N'/ ' +                                                             --fb_rke_vtweg
          N'/   ' +                                                           --fb_rke_werks
          N'/ ' +                                                             --fb_rke_kmbrnd
          N'/ ' +                                                             --fb_rke_kmcatg
          N'/         ' +                                                     --fb_rke_kmhi01
          N'/         ' +                                                     --fb_rke_kmhi02
          N'/         ' +                                                     --fb_rke_kmhi03
          N'/ ' +                                                             --fb_rke_kmkdgr
          N'/  ' +                                                            --fb_rke_kmland
          N'/        ' +                                                      --fb_rke_kmmakl
          N'/ ' +                                                             --fb_rke_kmniel
          N'/ ' +                                                             --fb_rke_kmstge
          N'/   ' +                                                           --fb_rke_kmvkbu
          N'/  ' +                                                            --fb_rke_kmvkgr
          N'/       ' +                                                       --fb_rke_kmvtnr
          N'/         ' +                                                     --fb_rke_pprctr
          N'/         ' +                                                     --fb_rke_copa_kostl
          N'/   ' +                                                           --fb_rke_ww904
          N'/ ' +                                                             --fb_rke_ww905
          N'/     ' +                                                         --fb_vbund
          N'/   ' +                                                           --fb_fkber
          N'/       ' +                                                       --fb_dabrz
          N'/' +                                                              --fb_xstba
          N'/  ' +                                                            --fb_rstgr
          N'/                       ' +                                       --fb_fipex
          N'/' +                                                              --fb_xnegp
          N'/ ' +                                                             --fb_gricd
          N'/  ' +                                                            --fb_grirg
          N'/ ' +                                                             --fb_gityp
          N'/ ' +                                                             --fb_fityp
          N'/ ' +                                                             --fb_stcdt
          N'/' +                                                              --fb_stkzn
          N'/                 ' +                                             --fb_stcd3
          N'/                 ' +                                             --fb_stcd4
          N'/                   ' +                                           --fb_xref3
          N'/                             ' +                                 --fb_kidno
          N'/ ' +                                                             --fb_dtws1
          N'/ ' +                                                             --fb_dtws2
          N'/ ' +                                                             --fb_dtws3
          N'/ ' +                                                             --fb_dtws4
          N'/ ' +                                                             --fb_dtaws
          N'/    ' +                                                          --fb_pycur
          N'/               ' +                                               --fb_pyamt
          N'/   ' +                                                           --fb_bupla
          N'/   ' +                                                           --fb_secco
          N'/     ' +                                                         --fb_lstar
          N'/         ' +                                                     --fb_egdeb
          N'/       ' +                                                       --fb_wenr
          N'/       ' +                                                       --fb_genr
          N'/       ' +                                                       --fb_grnr
          N'/       ' +                                                       --fb_menr
          N'/            ' +                                                  --fb_mive
          N'/   ' +                                                           --fb_nksl
          N'/    ' +                                                          --fb_empsl
          N'/            ' +                                                  --fb_svwnr
          N'/         ' +                                                     --fb_sberi
          N'/   ' +                                                           --fb_kkber
          N'/         ' +                                                     --fb_empfb
          N'/         ' +                                                     --fb_kursr_m
          N'/         ' +                                                     --fb_j_1kfrepre
          N'/                             ' +                                 --fb_j_1kftbus
          N'/                             ' +                                 --fb_j_1kftind
          N'/    ' +                                                          --fb_idxsp
          N'/              ' +                                                --fb_anred
          N'/            ' +                                                  --fb_recnnr
          N'/            ' +                                                  --fb_e_mive
          N'/                   ' +                                           --fb_bkref
          N'/' +                                                              --fb_dtams
          N'/ ' +                                                             --fb_cession_kz
          N'/                   ' +                                           --fb_grant_nbr
          N'/               ' +                                               --fb_fkber_long
          N'/' +                                                              --fb_erlkz
          N'/                                 ' +                             --fb_iban
          N'/       ' +                                                       --fb_valid_from
          N'/         ' +                                                     --fb_segment
          N'/         ' +                                                     --fb_psegment
          N'/    ' +                                                          --fb_hktid
          N'/' +                                                              --fb_xsiwe
          N'/' +                                                              --fb_sende
          N'/       '                                                         --fb_prodper
      AS exportline;

      SET @i = @i + 1;
  END;

  FETCH NEXT FROM fibuexp INTO @OrderByAutoInc, @KopfPos, @Art, @Belegdat, @WaeCode, @BelegNr, @Nettowert, @Bruttowert, @Steuerschl, @Debitor, @Gegenkonto, @Kostenstelle, @ZahlZiel, @BasisRechnung, @ProduktionFibuNr, @DetailNetto;
END;

CLOSE fibuexp;
DEALLOCATE fibuexp;

SELECT exportline FROM @output ORDER BY [Order] ASC;