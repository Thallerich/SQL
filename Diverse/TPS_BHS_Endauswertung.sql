SELECT Kunden.KdNr, Vsa.Bez AS VsaBezeichnung, Strumpf.Barcode, Status.Bez AS Status, Strumpf.Ruecklauf AS Waeschen, MIN(StrHist.Zeitpunkt) AS ErsterScan, MAX(StrHist.Zeitpunkt) AS LetzterScan
FROM Strumpf, StrHist, Status, Vsa, Kunden
WHERE StrHist.StrumpfID = Strumpf.ID
	AND Strumpf.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Strumpf.Status = Status.Status
	AND Status.Tabelle = 'STRHIST'
	AND Kunden.KdNr = 20152
GROUP BY Kunden.KdNr, Vsa.SuchCode, VsaBezeichnung, Strumpf.Barcode, Status, Waeschen
ORDER BY Kunden.KdNr, VsaBezeichnung, Status