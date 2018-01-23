SELECT ls.Datum, ls.Bez AS Status, COUNT(ls.LsNr)
FROM (
	SELECT LsKo.LsNr, LsKo.Datum, Status.Bez, COUNT(LsPo.ID) AS LsPoAnz
	FROM LsKo, Status, VsaBer, KdBer, LsPo
	WHERE LsKo.Status = Status.Status
	AND Status.Status <> 'W'
	AND Status.Tabelle = 'LSKO'
	AND LsKo.VsaID = VsaBer.VsaID
	AND VsaBer.KdBerID = KdBer.ID
	AND KdBer.BereichID = 102
	AND LsKo.Datum BETWEEN '01.01.2010' AND '30.10.2010'
	AND LsPo.LsKoID = LsKo.ID
	GROUP BY LsKo.LsNr, LsKo.Datum, Status.Bez
	HAVING LsPoAnz > 0
) ls
GROUP BY Datum, Status




SELECT Kunden.KdNr, TRIM(ISNULL(Kunden.Name1,''))+' '+TRIM(ISNULL(Kunden.Name2,''))+' '+TRIM(ISNULL(Kunden.Name3,'')) AS Kunde, Vsa.VsaNr, TRIM(ISNULL(Vsa.Name1,''))+' '+TRIM(ISNULL(Vsa.Name2,''))+' '+TRIM(ISNULL(Vsa.Name3,'')) AS Vsa, AnfKo.LieferDatum, AnfKo.AuftragsNr AS PackzettelNr, SUM(AnfPo.Angefordert) AnfMenge
FROM AnfKo, AnfPo, VsaBer, KdBer, Vsa, Kunden
WHERE AnfKo.LsKoID = -1
	AND AnfKo.LieferDatum BETWEEN '01.01.2010' AND '30.09.2010'
	AND AnfKo.PzGedruckt=true
	AND AnfPo.AnfKoID = AnfKo.ID
	AND AnfKo.VsaID = VsaBer.VsaID
	AND VsaBer.KdBerID = KdBer.ID
	AND KdBer.BereichID = 102
	AND AnfKo.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
GROUP BY 1,2,3,4,5,6
HAVING AnfMenge > 0
ORDER BY KdNr ASC 