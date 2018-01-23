SELECT kdarti.kundenid, artikel.suchcode, lpo.menge, lpo.lsnr, lpo.datum, lpo.bez
FROM kdarti, artikel, (
	SELECT lspo.kdartiid, lspo.menge, lko.lsnr, lko.datum, lko.bez
	FROM lspo, (	
		SELECT lsko.id, lsko.vsaid, lsko.lsnr, lsko.datum, lg.bez
		FROM lsko, (
			SELECT id, bez
			FROM lskogru
			WHERE id <> -1
		) lg
		WHERE lsko.lskogruid = lg.id
	) lko
	WHERE lspo.lskoid = lko.id
) lpo
WHERE kdarti.id = lpo.kdartiid AND kdarti.artikelid = artikel.id AND kdarti.kundenid = 3067
