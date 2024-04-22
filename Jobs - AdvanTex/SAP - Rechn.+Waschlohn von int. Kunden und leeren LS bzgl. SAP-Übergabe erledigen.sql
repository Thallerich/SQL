-- leere Lieferscheine bzgl. SAP-Übergabe erledigen
UPDATE LsKo
SET InternKalkFix = 1, SentToSAP = -1
WHERE LsKo.Status >= 'Q'
AND NOT EXISTS (SELECT LsPo.ID FROM LsPo WHERE LsPo.LsKoID = LsKo.ID AND  LsPo.Menge <> 0)
AND (LsKo.SentToSAP = 0 OR LsKo.InternKalkFix = 0);

-- Lieferscheine/Waschlöhne von internen Kunden bzgl. SAP-Übergabe erledigen
UPDATE LsKo
SET InternKalkFix = 1, SentToSAP = -1
FROM vsa, kunden
WHERE lsko.VsaID = vsa.id
AND vsa.kundenid = kunden.id
AND LsKo.Status >= 'Q'
AND (LsKo.SentToSAP = 0 OR LsKo.InternKalkFix = 0)
AND kunden.KdGfID NOT IN (SELECT ID FROM KdGf WHERE KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU', N'BM', N'RT', N'MIC'));

-- Rechnungen von internen Kunden bzgl. SAP-Übergabe erledigen
UPDATE RechKo
SET FiBuExpID = -2
FROM Kunden
WHERE RechKo.kundenID = Kunden.ID
AND RechKo.FiBuExpID = -1
AND RechKo.Status >= 'N'
AND kunden.KdGfID NOT IN (SELECT ID FROM KdGf WHERE KurzBez IN (N'MED', N'GAST', N'JOB', N'SAEU', N'BM', N'RT', N'MIC'));