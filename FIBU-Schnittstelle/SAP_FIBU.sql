/*******************************************************************************************************************************
**                                                                                                                            **
** FIBU-Export zu ITM - erstellt von Stefan Thaller, Wozabal Miettex GmbH, 24.07.2019, Version 3.0                            **
** laut Schnittstellenbeschreibung: Doku_Schnittstelle-ITM-SAP_SMRO.xls                                                       **
**                                                                                                                            **
** ACHTUNG: Alle Felder haben vorgegeben Längen - bei Änderungen am Skript beachten, dass diese gleich bleiben!               **
**                                                                                                                            **
*******************************************************************************************************************************/

DECLARE @OrderByAutoInc int;
DECLARE @KopfPos nchar(1);
DECLARE @Art nchar(2);
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
DECLARE @KdGfFibuNr nchar(4);
DECLARE @Buchungskreis int;

DECLARE @i int = 0;

DECLARE @output TABLE ([Order] int, exportline nvarchar(max));

DECLARE fibuexp CURSOR LOCAL FAST_FORWARD FOR
  SELECT Export.OrderByAutoInc, Export.KopfPos,
    Belegart =
      CASE
        WHEN Firma.SuchCode = N'FA14' AND Export.Art = N'R' THEN N'AU'
        WHEN Firma.SuchCode = N'SMP' AND Export.Art = N'R' THEN N'VF'
        WHEN Firma.SuchCode = N'WOMI' AND Export.Art = N'R' THEN N'AR'
        WHEN Firma.SuchCode = N'UKLU' AND Export.Art = N'R' THEN N'AR'
        WHEN Firma.SuchCode = N'SMKR' AND Export.Art = N'R' THEN N'__'
        WHEN Firma.SuchCode = N'FA14' AND Export.Art = N'G' THEN N'GA'
        WHEN Firma.SuchCode = N'SMP' AND Export.Art = N'G' THEN N'VS'
        WHEN Firma.SuchCode = N'WOMI' AND Export.Art = N'G' THEN N'GU'
        WHEN Firma.SuchCode = N'UKLU' AND Export.Art = N'G' THEN N'GU'
        WHEN Firma.SuchCode = N'SMKR' AND Export.Art = N'G' THEN N'__'
        ELSE N'XX'
      END,
    Export.Belegdat, Wae.IsoCode AS WaeCode, Export.BelegNr, Export.Nettowert, IIF(Wae.IsoCode = N'CZK', Export.Bruttowert, Export.Bruttowert) AS Bruttowert,
    Steuerschl =
      CASE
        WHEN MwSt.SteuerSchl = N'6Z' AND Export.Art = N'G' AND Firma.SuchCode = N'SMP' THEN N'6O'
        WHEN MwSt.Steuerschl = N'A6' AND Firma.SuchCode = N'SMP' THEN N'33'
        ELSE MwSt.Steuerschl
      END,
    Export.Debitor, Export.Gegenkonto, 
    Kostenstelle =
      CASE
        WHEN Export.Gegenkonto = N'480004' AND KdGf.KurzBez = N'JOB' THEN N'1400'
        WHEN Export.Gegenkonto = N'480004' AND KdGf.KurzBez = N'MED' THEN N'2400'
        WHEN Export.Gegenkonto = N'480004' AND KdGf.KurzBez = N'GAST' THEN N'1310'
        ELSE Export.Kostenstelle
      END,
    Export.ZahlZiel, IIF(RechKo.BasisRechKoID > 0 AND RechKo.Art = N'G', CAST(BasisRechKo.RechNr AS nchar(10)), NULL) AS BasisRechnung,
    KdGfFibuNr = 
      CASE
        WHEN Firma.SuchCode = N'UKLU' THEN CAST(93 AS nchar(3))
        WHEN Firma.SuchCode = N'FA14' AND Standort.SuchCode = N'UKLU' THEN CAST(90 AS nchar(3))  --Salesianer SÜD
        WHEN Firma.SuchCode = N'FA14' AND Standort.SuchCode <> N'UKLU' THEN CAST(40 AS nchar(3))  --Salesianer WEST
        WHEN Firma.SuchCode = N'SMP' THEN CAST(895 AS nchar(3))
        WHEN Firma.SuchCode = N'SMKR' THEN CAST(770 AS nchar(3))
        ELSE CAST(KdGf.FibuNr AS nchar(3))
      END,
    Buchungskreis = 
      CASE Firma.SuchCode 
        WHEN N'UKLU' THEN 1260
        WHEN N'FA14' THEN 1200
        WHEN N'WOMI' THEN 1250
        WHEN N'SMP' THEN 1900
        WHEN N'SMKR' THEN 1610
        ELSE 1250
      END
  FROM #bookingexport AS Export
  JOIN RechKo ON Export.RechKoID = RechKo.ID
  JOIN RechKo AS BasisRechKo ON RechKo.BasisRechKoID = BasisRechKo.ID
  JOIN Wae ON RechKo.WaeID = Wae.ID
  JOIN Kunden ON RechKo.KundenID = Kunden.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN Firma ON RechKo.FirmaID = Firma.ID
  JOIN MwSt ON RechKo.MwStID = MwSt.ID
  WHERE Export.KopfPos IN (N'K', N'P')
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

FETCH NEXT FROM fibuexp INTO @OrderByAutoInc, @KopfPos, @Art, @Belegdat, @WaeCode, @BelegNr, @Nettowert, @Bruttowert, @Steuerschl, @Debitor, @Gegenkonto, @Kostenstelle, @ZahlZiel, @BasisRechnung, @KdGfFibuNr, @Buchungskreis;

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
        @Art +                                                              --fk_blart
        CAST(@Buchungskreis AS nchar(4)) +                                  --fk_bukrs
        FORMAT(@Belegdat, 'ddMMyyyy', 'de-AT') +                            --fk_budat
        N'/ ' +                                                             --fk_monat
        CAST(ISNULL(@WaeCode, N'') AS nchar(5)) +                           --fK_waers
        N'/         ' +                                                     --fk_kursf
        CAST(@BelegNr AS nchar(10)) +                                       --fk_belnr
        N'/       ' +                                                       --fk_wwert
        @Art + CAST(@BelegNr AS nchar(14)) +                                --fk_xblnr
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
        IIF(@Bruttowert < 0, N'11', N'01') +                                      --fb_newbs
        N'/         ' +                                                           --fb_dummy
        N'/' +                                                                    --fb_newum
        N'/   ' +                                                                 --fb_newbk
        CAST(FORMAT(ABS(IIF(@WaeCode = N'CZK', ROUND(@Bruttowert, 0), @Bruttowert)), 'F2', 'de-AT') AS nchar(16)) +    --fb_wrbtr
        N'/               ' +                                                     --fb_dmbtr
        N'/               ' +                                                     --fb_wmwst
        N'/               ' +                                                     --fb_mwsts
        CAST(ISNULL(@Steuerschl, N'') AS nchar(2)) +                              --fb_mwskz
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
        CAST(ISNULL(@ZahlZiel, N'') AS nchar(4)) +                                --fb_zterm  
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
        LEFT(ISNULL(@Debitor, CAST(N'' AS nchar(24))), 17) +                      --fb_newko
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

  IF @KopfPos = N'P'
  BEGIN
    -- BBESG-ERLKTO - Belegkopf für Buchhaltungsbeleg - Erlöskontobuchung
    INSERT INTO @output
    SELECT @i AS [Order], 
      N'2' +                                                                                          --fb_fbs_stype
        N'ZBSEG                         ' +                                                           --fb_tbnam
        IIF(@Bruttowert < 0, N'40', N'50') +                                                          --fb_newbs
        N'/         ' +                                                                               --fb_dummy
        N'/' +                                                                                        --fb_newum
        N'/   ' +                                                                                     --fb_newbk
        CAST(FORMAT(ABS(@Bruttowert), 'F2', 'de-AT') AS nchar(16)) +                                  --fb_wrbtr
        N'/               ' +                                                                         --fb_dmbtr
        N'/               ' +                                                                         --fb_wmwst
        N'/               ' +                                                                         --fb_mwsts
        N'/ ' +                                                                                       --fb_mwskz
        N'/' +                                                                                        --fb_xskrl
        N'/               ' +                                                                         --fb_fwzuz
        N'/               ' +                                                                         --fb_hwzuz
        N'/   ' +                                                                                     --fb_gsber
        CAST(RTRIM(ISNULL(@KdGfFibuNr, N'')) + ISNULL(@Kostenstelle, N'') AS nchar(10)) +             --fb_kostl
        N'/   ' +                                                                                     --fb_dummy4
        N'/           ' +                                                                             --fb_aufnr
        N'/         ' +                                                                               --fb_ebeln
        N'/    ' +                                                                                    --fb_ebelp
        N'/               ' +                                                                         --fb_projn
        N'/                 ' +                                                                       --fb_matnr
        N'/   ' +                                                                                     --fb_werks
        N'/                ' +                                                                        --fb_menge
        N'/  ' +                                                                                      --fb_meins
        N'/         ' +                                                                               --fb_vbel2
        N'/     ' +                                                                                   --fb_posn2
        N'/   ' +                                                                                     --fb_eten2
        N'/       ' +                                                                                 --fb_pernr
        N'/  ' +                                                                                      --fb_bewar
        N'/       ' +                                                                                 --fb_valut
        N'/       ' +                                                                                 --fb_zfbdt
        N'/ ' +                                                                                       --fb_zinkz
        LEFT(ISNULL(@Debitor, CAST(N'' AS nchar(24))), 18) +                                          --fb_zuor
        N'/  ' +                                                                                      --fb_fkont
        N'/' +                                                                                        --fb_xaabg
        N'+                                                 ' +                                       --fb_sgtxt
        N'/ ' +                                                                                       --fb_blnkz
        N'/               ' +                                                                         --fb_blnbt
        N'/       ' +                                                                                 --fb_blnpz
        N'/ ' +                                                                                       --fb_maber
        N'/               ' +                                                                         --fb_skfbt
        N'/               ' +                                                                         --fb_wskto
        N'/   ' +                                                                                     --fb_zterm
        N'/  ' +                                                                                      --fb_zbd1t
        N'/     ' +                                                                                   --fb_zbd1p
        N'/  ' +                                                                                      --fb_zbd2t
        N'/     ' +                                                                                   --fb_z2d2p
        N'/  ' +                                                                                      --fb_zbd3t
        N'/' +                                                                                        --fb_zlspr
        N'/         ' +                                                                               --fb_rebzg
        N'/   ' +                                                                                     --fb_rebzj
        N'/  ' +                                                                                      --fb_rebzz
        N'/' +                                                                                        --fb_zlsch
        N'/       ' +                                                                                 --fb_samnr
        N'/' +                                                                                        --fb_zbfix
        N'/ ' +                                                                                       --fb_qsskz
        N'/               ' +                                                                         --fb_qsshb
        N'/               ' +                                                                         --fb_qsfbt
        N'/          ' +                                                                              --fb_esrnr
        N'/ ' +                                                                                       --fb_esrpz
        N'/                          ' +                                                              --fb_esrre
        N'/       ' +                                                                                 --fb_fdtag
        N'/ ' +                                                                                       --fb_dflev
        N'/           ' +                                                                             --fb_anln1
        N'/   ' +                                                                                     --fb_anln2
        N'/       ' +                                                                                 --fb_bzdat
        N'/  ' +                                                                                      --fb_anbwa
        N'/      ' +                                                                                  --fb_abper
        N'/               ' +                                                                         --fb_gbetr
        N'/         ' +                                                                               --fb_kursr
        N'/' +                                                                                        --fb_mansp
        N'/' +                                                                                        --fb_mschl
        N'/    ' +                                                                                    --fb_hbkid
        N'/   ' +                                                                                     --fb_bvtyp
        N'/         ' +                                                                               --fb_anfbn
        N'/   ' +                                                                                     --fb_anfbu
        N'/   ' +                                                                                     --fb_anfbj
        N'/  ' +                                                                                      --fb_lzbkz
        N'/  ' +                                                                                      --fb_landl
        N'/' +                                                                                        --fb_diekz
        N'/       ' +                                                                                 --fb_zolld
        N'/       ' +                                                                                 --fb_zollt
        N'/       ' +                                                                                 --fb_vrsdt
        N'/' +                                                                                        --fb_vrskz
        N'/                 ' +                                                                       --fb_hzuon
        N'/' +                                                                                        --fb_regul
        N'/                                  ' +                                                      --fb_name1
        N'/                                  ' +                                                      --fb_name2
        N'/                                  ' +                                                      --fb_name3
        N'/                                  ' +                                                      --fb_name4
        N'/                                  ' +                                                      --fb_stras
        N'/                                  ' +                                                      --fb_ort01
        N'/         ' +                                                                               --fb_pstlz
        N'/  ' +                                                                                      --fb_land1
        N'/  ' +                                                                                      --fb_regio
        N'/              ' +                                                                          --fb_bankl
        N'/  ' +                                                                                      --fb_banks
        N'/                 ' +                                                                       --fb_bankn
        N'/ ' +                                                                                       --fb_bkont
        N'/               ' +                                                                         --fb_stcd1
        N'/          ' +                                                                              --fb_stcd2
        N'/       ' +                                                                                 --fb_madat
        N'/' +                                                                                        --fb_manst
        N'/  ' +                                                                                      --fb_egmld
        N'/  ' +                                                                                      --fb_dummy2
        N'/                   ' +                                                                     --fb_stceg
        N'/' +                                                                                        --fb_stkza
        N'/' +                                                                                        --fb_stkzu
        N'/         ' +                                                                               --fb_pfach
        N'/         ' +                                                                               --fb_pstl2
        N'/' +                                                                                        --fb_spras
        N'/' +                                                                                        --fb_xinve
        CAST(ISNULL(@Gegenkonto, N'') AS nchar(17)) +                                                 --fb_newko
        N'/  ' +                                                                                      --fb_newbw
        N'/                ' +                                                                        --fb_knrze
        N'/         ' +                                                                               --fb_hkont
        N'/         ' +                                                                               --fb_prctr
        N'/            ' +                                                                            --fb_vertn
        N'/' +                                                                                        --fb_vertt
        N'/   ' +                                                                                     --fb_vbewa
        N'/               ' +                                                                         --fb_hwbas
        N'/               ' +                                                                         --fb_fwbas
        N'/             ' +                                                                           --fb_fipos
        N'/     ' +                                                                                   --fb_vname
        N'/  ' +                                                                                      --fb_egrup
        N'/ ' +                                                                                       --fb_btype
        N'/         ' +                                                                               --fb_paobjnr
        N'/           ' +                                                                             --fb_kstgr
        N'/       ' +                                                                                 --fb_imkey
        N'/       ' +                                                                                 --fb_dummy3
        N'/         ' +                                                                               --fb_vptnr
        N'/           ' +                                                                             --fb_nplnr
        N'/   ' +                                                                                     --fb_vornr
        N'/' +                                                                                        --fb_xegdr
        N'/ ' +                                                                                       --fb_recid
        N'/         ' +                                                                               --fb_prrct
        N'/                       ' +                                                                 --fb_projk
        N'/ ' +                                                                                       --fb_uzawe
        N'/              ' +                                                                          --fb_txjcd
        N'/               ' +                                                                         --fb_fistl
        N'/         ' +                                                                               --fb_geber
        N'/               ' +                                                                         --fb_dmbe2
        N'/               ' +                                                                         --fb_dmbe3
        N'/   ' +                                                                                     --fb_pargb
        N'/           ' +                                                                             --fb_xref1
        N'/           ' +                                                                             --fb_xref2
        N'/         ' +                                                                               --fb_kblnr
        N'/  ' +                                                                                      --fb_kblpos
        N'/       ' +                                                                                 --fb_wdate
        N'/' +                                                                                        --fb_wgbkz
        N'/' +                                                                                        --fb_xaktz
        N'/                             ' +                                                           --fb_wname
        N'/                             ' +                                                           --fb_wort1
        N'/                             ' +                                                           --fb_wbzog
        N'/                             ' +                                                           --fb_wort2
        N'/                                                           ' +                             --fb_wbank
        N'/                                                           ' +                             --fb_wlzbp
        N'/       ' +                                                                                 --fb_diskp
        N'/  ' +                                                                                      --fb_diskt
        N'/               ' +                                                                         --fb_winfw
        N'/               ' +                                                                         --fb_winhw
        N'/' +                                                                                        --fb_wevwv
        N'/' +                                                                                        --fb_wstat
        N'/ ' +                                                                                       --fb_wmwkz
        N'/' +                                                                                        --fb_wstkz
        N'/                 ' +                                                                       --fb_rke_artnr
        N'/ ' +                                                                                       --fb_rke_bonus
        N'/   ' +                                                                                     --fb_rke_brsch
        N'/   ' +                                                                                     --fb_rke_burks
        N'/     ' +                                                                                   --fb_rke_bzrik
        N'/    ' +                                                                                    --fb_rke_eform
        N'/   ' +                                                                                     --fb_rke_fkart
        N'/   ' +                                                                                     --fb_rke_gebie
        N'/   ' +                                                                                     --fb_rke_gsber
        N'/         ' +                                                                               --fb_rke_kaufn
        N'/ ' +                                                                                       --fb_rke_kdgrp
        N'/     ' +                                                                                   --fb_rke_kdpos
        N'/         ' +                                                                               --fb_rke_kndnr
        N'/   ' +                                                                                     --fb_rke_kokrs
        N'/           ' +                                                                             --fb_rke_kstrg
        N'/  ' +                                                                                      --fb_rke_land1
        N'/' +                                                                                        --fb_rke_maabc
        N'/        ' +                                                                                --fb_rke_matkl
        N'/         ' +                                                                               --fb_rke_prctr
        N'/                       ' +                                                                 --fb_rke_pspnr
        N'/           ' +                                                                             --fb_rke_rkaufnr
        N'/ ' +                                                                                       --fb_rke_spart
        N'/   ' +                                                                                     --fb_rke_vkbur
        N'/  ' +                                                                                      --fb_rke_vkgrp
        N'/   ' +                                                                                     --fb_rke_vkorg
        N'/ ' +                                                                                       --fb_rke_vtweg
        N'/   ' +                                                                                     --fb_rke_werks
        N'/ ' +                                                                                       --fb_rke_kmbrnd
        N'/ ' +                                                                                       --fb_rke_kmcatg
        N'/         ' +                                                                               --fb_rke_kmhi01
        N'/         ' +                                                                               --fb_rke_kmhi02
        N'/         ' +                                                                               --fb_rke_kmhi03
        N'/ ' +                                                                                       --fb_rke_kmkdgr
        N'/  ' +                                                                                      --fb_rke_kmland
        N'/        ' +                                                                                --fb_rke_kmmakl
        N'/ ' +                                                                                       --fb_rke_kmniel
        N'/ ' +                                                                                       --fb_rke_kmstge
        N'/   ' +                                                                                     --fb_rke_kmvkbu
        N'/  ' +                                                                                      --fb_rke_kmvkgr
        N'/       ' +                                                                                 --fb_rke_kmvtnr
        N'/         ' +                                                                               --fb_rke_pprctr
        N'/         ' +                                                                               --fb_rke_copa_kostl
        N'/   ' +                                                                                     --fb_rke_ww904
        N'/ ' +                                                                                       --fb_rke_ww905
        N'/     ' +                                                                                   --fb_vbund
        N'/   ' +                                                                                     --fb_fkber
        N'/       ' +                                                                                 --fb_dabrz
        N'/' +                                                                                        --fb_xstba
        N'/  ' +                                                                                      --fb_rstgr
        N'/                       ' +                                                                 --fb_fipex
        N'/' +                                                                                        --fb_xnegp
        N'/ ' +                                                                                       --fb_gricd
        N'/  ' +                                                                                      --fb_grirg
        N'/ ' +                                                                                       --fb_gityp
        N'/ ' +                                                                                       --fb_fityp
        N'/ ' +                                                                                       --fb_stcdt
        N'/' +                                                                                        --fb_stkzn
        N'/                 ' +                                                                       --fb_stcd3
        N'/                 ' +                                                                       --fb_stcd4
        N'/                   ' +                                                                     --fb_xref3
        N'/                             ' +                                                           --fb_kidno
        N'/ ' +                                                                                       --fb_dtws1
        N'/ ' +                                                                                       --fb_dtws2
        N'/ ' +                                                                                       --fb_dtws3
        N'/ ' +                                                                                       --fb_dtws4
        N'/ ' +                                                                                       --fb_dtaws
        N'/    ' +                                                                                    --fb_pycur
        N'/               ' +                                                                         --fb_pyamt
        N'/   ' +                                                                                     --fb_bupla
        N'/   ' +                                                                                     --fb_secco
        N'/     ' +                                                                                   --fb_lstar
        N'/         ' +                                                                               --fb_egdeb
        N'/       ' +                                                                                 --fb_wenr
        N'/       ' +                                                                                 --fb_genr
        N'/       ' +                                                                                 --fb_grnr
        N'/       ' +                                                                                 --fb_menr
        N'/            ' +                                                                            --fb_mive
        N'/   ' +                                                                                     --fb_nksl
        N'/    ' +                                                                                    --fb_empsl
        N'/            ' +                                                                            --fb_svwnr
        N'/         ' +                                                                               --fb_sberi
        N'/   ' +                                                                                     --fb_kkber
        N'/         ' +                                                                               --fb_empfb
        N'/         ' +                                                                               --fb_kursr_m
        N'/         ' +                                                                               --fb_j_1kfrepre
        N'/                             ' +                                                           --fb_j_1kftbus
        N'/                             ' +                                                           --fb_j_1kftind
        N'/    ' +                                                                                    --fb_idxsp
        N'/              ' +                                                                          --fb_anred
        N'/            ' +                                                                            --fb_recnnr
        N'/            ' +                                                                            --fb_e_mive
        N'/                   ' +                                                                     --fb_bkref
        N'/' +                                                                                        --fb_dtams
        N'/ ' +                                                                                       --fb_cession_kz
        N'/                   ' +                                                                     --fb_grant_nbr
        N'/               ' +                                                                         --fb_fkber_long
        N'/' +                                                                                        --fb_erlkz
        N'/                                 ' +                                                       --fb_iban
        N'/       ' +                                                                                 --fb_valid_from
        N'/         ' +                                                                               --fb_segment
        N'/         ' +                                                                               --fb_psegment
        N'/    ' +                                                                                    --fb_hktid
        N'/' +                                                                                        --fb_xsiwe
        N'/' +                                                                                        --fb_sende
        N'/       '                                                                                   --fb_prodper
    AS exportline;

    SET @i = @i + 1;
  END;

  FETCH NEXT FROM fibuexp INTO @OrderByAutoInc, @KopfPos, @Art, @Belegdat, @WaeCode, @BelegNr, @Nettowert, @Bruttowert, @Steuerschl, @Debitor, @Gegenkonto, @Kostenstelle, @ZahlZiel, @BasisRechnung, @KdGfFibuNr, @Buchungskreis;
END;

CLOSE fibuexp;
DEALLOCATE fibuexp;

SELECT exportline FROM @output ORDER BY [Order] ASC;
