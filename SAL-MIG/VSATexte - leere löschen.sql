DELETE FROM VsaTexte 
WHERE REPLACE(REPLACE(Memo, CHAR(10), ''), CHAR(13), '') = ''
  OR Memo = '.';

UPDATE VsaTexte SET Memo = RIGHT(VsaTexte.Memo, LEN(VsaTexte.Memo) - 2)
--SELECT VsaTexte.Memo, REPLACE(REPLACE(Memo, CHAR(10), ''), CHAR(13), '<Enter>') AS MemoAlt, RIGHT(VsaTexte.Memo, LEN(VsaTexte.Memo) - 2) AS MemoNeu
--FROM VsaTexte
WHERE LEFT(VsaTexte.Memo, 2) = CHAR(13) + CHAR(10)
  AND VsaTexte.TextArtID = 12;