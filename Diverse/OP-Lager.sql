
-- # Über ZielNummern (besser, weil Teile von Qualitätskontrolle ins Lager gegeben werden sollen)

UPDATE OpTeile
SET OpTeile.ZielNrID = 10000035 --, OpTeile.Status = 'E'
FROM OpTeile, (
	SELECT OpTeile.ID, OpScans.ID
	FROM OpTeile
	LEFT OUTER JOIN OpScans ON OpScans.OpTeileID = OpTeile.ID
	--WHERE OpTeile.Status = 'R'
	WHERE OpScans.ID IS NULL
) OpAltTeile
WHERE OpTeile.ID = OpAltTeile.ID;





-- # Mit der OP-Lager-Funktionaliät von AdvanTex
UPDATE OpTeile
SET OpTeile.OpLagerID = 4549, OpTeile.Status = 'E'
FROM OpTeile
LEFT OUTER JOIN OpScans ON OpScans.OpTeileID = OpTeile.ID
WHERE OpTeile.Status NOT IN ('Z', 'E')
  AND OpScans.Zeitpunkt IS NULL;