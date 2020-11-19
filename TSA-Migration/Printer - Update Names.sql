UPDATE RptDruck SET DruckerName = N'\\' + LOWER(__TSPrinter.Servername) + N'.sal.co.at\' + __TSPrinter.PrinternameNew, Bez = __TSPrinter.PrinternameNew
FROM RptDruck
JOIN __TSPrinter ON RptDruck.DruckerName = __TSPrinter.PrinternameOld;

GO