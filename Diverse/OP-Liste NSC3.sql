SELECT 
  KdNr,
  SuchCode,
  [Vsa Bezeichnung],
  RIGHT(RTRIM([Bestellung bis xxx möglich]), 5) AS [Bestellung bis],
  STUFF((SELECT '+' + o.Montag FROM _OPListe o WHERE o.KdNr = _OPListe.KdNr AND o.Montag IS NOT NULL ORDER BY o.Montag FOR XML PATH('')),1,1,'') AS Montag,
  STUFF((SELECT '+' + o.Dienstag FROM _OPListe o WHERE o.KdNr = _OPListe.KdNr AND o.Dienstag IS NOT NULL ORDER BY o.Dienstag FOR XML PATH('')),1,1,'') AS Dienstag,
  STUFF((SELECT '+' + o.Mittwoch FROM _OPListe o WHERE o.KdNr = _OPListe.KdNr AND o.Mittwoch IS NOT NULL ORDER BY o.Mittwoch FOR XML PATH('')),1,1,'') AS Mittwoch,
  STUFF((SELECT '+' + o.Donnerstag FROM _OPListe o WHERE o.KdNr = _OPListe.KdNr AND o.Donnerstag IS NOT NULL ORDER BY o.Donnerstag FOR XML PATH('')),1,1,'') AS Donnerstag,
  STUFF((SELECT '+' + o.Freitag FROM _OPListe o WHERE o.KdNr = _OPListe.KdNr AND o.Freitag IS NOT NULL ORDER BY o.Freitag FOR XML PATH('')),1,1,'') AS Freitag,
  STUFF((SELECT '+' + o.Samstag FROM _OPListe o WHERE o.KdNr = _OPListe.KdNr AND o.Samstag IS NOT NULL ORDER BY o.Samstag FOR XML PATH('')),1,1,'') AS Samstag,
  ISNULL(Ansprechpartner, '') + IIF(Ansprechpartner IS NULL, '', '  ') + ISNULL(Telefonnummer, '') AS Ansprechpartner
FROM _OPListe
GROUP BY KdNr, SuchCode, [Vsa Bezeichnung], RIGHT(RTRIM([Bestellung bis xxx möglich]), 5), ISNULL(Ansprechpartner, '') + IIF(Ansprechpartner IS NULL, '', '  ') + ISNULL(Telefonnummer, '')

GO