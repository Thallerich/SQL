UPDATE Settings SET ValueMemo = REPLACE(Settings.ValueMemo, N'ATENADVANTEX01.wozabal.int', N'SALADVPAPP1.salres.com')
WHERE ValueMemo LIKE N'%ATENADVANTEX01%';