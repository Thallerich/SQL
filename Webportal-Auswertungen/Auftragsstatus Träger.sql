/* Läuft direkt im Webportal */

SELECT msgTrae.MsgNo AS \"$lang_messageid\",
  CASE
    WHEN msgTraeA.Status = 'A' THEN \"$lang_wm_status_erfasst\"
    WHEN msgTraeA.Status = 'E' THEN \"$lang_wm_status_abgeholt\"
    WHEN msgTraeA.Status = 'K' THEN \"$lang_wm_status_fehler\"
    WHEN msgTraeA.Status = 'U' THEN \"$lang_wm_status_abgelehnt\"
    WHEN msgTraeA.Status = 'V' THEN \"$lang_wm_status_akzeptiert\"
    WHEN msgTraeA.Status = 'Z' THEN \"$lang_wm_status_verarbeitet\"
    WHEN msgTraeA.Status = 'B' THEN \"$lang_wm_status_freigabe_offen\"
    WHEN msgTraeA.Status = 'C' THEN \"$lang_wm_status_freigabe_abgelehnt\"
    WHEN msgTraeA.Status = 'H' THEN \"$lang_wm_status_freigabe\"
    ELSE '?'
  END AS \"$lang_status\",
  CASE
    WHEN msgTraeA.Typ = 'NO_CHANGE' THEN '?'
    WHEN msgTraeA.Typ = 'ADD_RESIDENT' THEN \"$lang_wmt_add_resident\"
    WHEN msgTraeA.Typ = 'EDIT_RESIDENT' THEN \"$lang_wmt_edit_resident\"
    WHEN msgTraeA.Typ = 'DELETE_RESIDENT' THEN \"$lang_wmt_delete_resident\"
    WHEN msgTraeA.Typ = 'ACTIVATE_RESIDENT' THEN \"$lang_wmt_activate_resident\"
    WHEN msgTraeA.Typ = 'DEACTIVATE_RESIDENT' THEN \"$lang_wmt_deactivate_resident\"
    WHEN msgTraeA.Typ = 'ADD_WEARER' THEN \"$lang_wmt_add_wearer\"
    WHEN msgTraeA.Typ = 'EDIT_WEARER' THEN \"$lang_wmt_edit_wearer\"
    WHEN msgTraeA.Typ = 'EDIT_WEARER_KREDIT' THEN \"$lang_planmenge_aenderung\"
    WHEN msgTraeA.Typ = 'DELETE_WEARER' THEN \"$lang_wmt_delete_wearer\"
    WHEN msgTraeA.Typ = 'ACTIVATE_WEARER' THEN \"$lang_wmt_activate_wearer\"
    WHEN msgTraeA.Typ = 'DEACTIVATE_WEARER' THEN \"$lang_wmt_deactivate_wearer\"
    WHEN msgTraeA.Typ = 'DELETE_LOCKER' THEN \"$lang_wmt_delete_locker\"
    WHEN msgTraeA.Typ = 'ADD_TRAEARTI' THEN \"$lang_wmt_add_traearti\"
    WHEN msgTraeA.Typ = 'ADD_TRAEARTI_RENTO' THEN \"$lang_wmt_add_traearti_rento\"
    WHEN msgTraeA.Typ = 'ADD_TRAEARTI_AUSSTA' THEN \"$lang_wmt_add_traearti_aussta\"
    WHEN msgTraeA.Typ = 'DELETE_TRAEARTI' THEN \"$lang_wmt_delete_traearti\"
    WHEN msgTraeA.Typ = 'ADD_TRAEMASS' THEN \"$lang_wmt_add_traemass\"
    WHEN msgTraeA.Typ = 'CHANGE_TA_ARTICLE' THEN \"$lang_wmt_change_ta_article\"
    WHEN msgTraeA.Typ = 'CHANGE_TA_AMOUNT' AND msgTraeA.Aufstockung = 1 THEN \"$lang_wmt_change_ta_amount_inc\"
    WHEN msgTraeA.Typ = 'CHANGE_TA_AMOUNT' AND msgTraeA.Aufstockung = 0 THEN \"$lang_wmt_change_ta_amount_dec\"
    WHEN msgTraeA.Typ = 'CHANGE_TA_SIZE' THEN \"$lang_wmt_change_ta_size\"
    WHEN msgTraeA.Typ = 'CHANGE_VSANF_AMOUNT' THEN \"$lang_VsaAnfMengenAenderungen\"
    WHEN msgTraeA.Typ = 'ADD_ONETIME_DELIVERY' THEN \"$lang_onetime_delivery\"
    WHEN msgTraeA.Typ = 'EXCHANGE_PIECE' THEN \"$lang_piece_exchange\"
    WHEN msgTraeA.Typ = 'TRAEGER_IMPORT' THEN \"$lang_traeger_import\"
    ELSE '?'
  END AS \"$lang_messagetype\",
  msgTrae.Vorname AS \"$lang_firstname\",
  msgTrae.Nachname AS \"$lang_lastname\",
  msgTrae.Titel AS \"$lang_title\",
  Artikel.ArtikelNr AS \"$lang_article_no\",
  Artikel.ArtikelBez%LAN% AS \"$lang_bez\",
  ArtGroe.Groesse AS \"$lang_groesse\",
  msgTraeA.Menge AS \"$lang_menge\",
  msgTraeA.Anlage_ AS \"$lang_erfasst_am\",
  WebUser.UserName AS \"$lang_erfasst_von\",
  VSA.Bez AS \"$lang_vsa\"
FROM msgTraeA
JOIN msgTrae ON msgTraeA.MsgNo = msgTrae.MsgNo
JOIN KdArti ON msgTraeA.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN ArtGroe ON msgTraeA.ArtGroeID = ArtGroe.ID
JOIN VSA ON msgTrae.VsaID = VSA.ID
JOIN WebUser ON msgTraeA.WebUserID = WebUser.ID
WHERE VSA.KundenID = " . $kundenID . "
ORDER BY 1 DESC;