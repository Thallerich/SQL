SELECT N'0FAKTURA     100SAITM               X/' AS ExportText
UNION
SELECT '1FB01                ' + FORMAT(BelegDat_, 'ddMMyyyy', 'de-AT') + 'AR1200' + FORMAT(BelegDat_, 'ddMMyyyy', 'de-AT') + '/ EUR  /         10059033  /       AR10059033      /               /                            /       /     X/         /                                       /       /   /  / /         /                                                 ///   /            /'
FROM #bookingexport;