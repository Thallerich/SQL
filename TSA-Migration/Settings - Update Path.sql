UPDATE Settings SET ValueMemo = REPLACE(Settings.ValueMemo, N'ATENADVANTEX01.wozabal.int', N'SALADVPAPP.sal.co.at')
WHERE ValueMemo LIKE N'%ATENADVANTEX01%';