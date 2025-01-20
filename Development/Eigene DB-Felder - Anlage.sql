INSERT INTO TabField (TabNameID, Pos, Name, [Type], [Len], Bez, BezEN, LabelText, NotNullDD, RefTableName, RefFieldName, AllowMinus1, DefaultValue, DefaultValue2, HideInTable, PageName, PagePos, IgnoreRefCheckMsSQL, AnlageUserID_, UserID_, WaehleSQL)
VALUES (10349, 1005, N'_KIBKKlinikBereich', N'n', 200, N'Klinik / Bereich',      N'Klinik / Bereich',             N'Klinik / Bereich:',           0, NULL,   NULL,  0, NULL,  NULL,  1, N'KIBK',               10, 1, 9245, 9245, NULL),
       (10349, 1006, N'_KIBKBereichVerw',   N'n', 200, N'Bereichsverwaltung',    N'Bereichsverwaltung',           N'Bereichsverwaltung:',         0, NULL,   NULL,  0, NULL,  NULL,  1, N'KIBK',               20, 1, 9245, 9245, NULL),
       (10349, 1007, N'_KIBKArt',           N'n', 200, N'Art',                   N'Art',                          N'Art:',                        0, NULL,   NULL,  0, NULL,  NULL,  1, N'KIBK',               30, 1, 9245, 9245, NULL),
       (10349, 1008, N'_KIBKBereich',       N'n', 200, N'Bereich',               N'Bereich',                      N'Bereich:',                    0, NULL,   NULL,  0, NULL,  NULL,  1, N'KIBK',               40, 1, 9245, 9245, NULL),
       (10236, 1012, N'_CHAbcID',           N'I', 0,   N'ABC-Klasse Schweiz',    N'ABC-Class Switzerland',        N'ABC-Klasse CH:',              1, N'ABC', N'ID', 1, N'-1', N'-1', 1, N'ABC-Klassen Länder', 40, 1, 9245, 9245, N'SELECT ID, ABCBez FROM ABC WHERE Artikel = 1 ORDER BY ABC.ABC;'),
       (10236, 1013, N'_CZAbcID',           N'I', 0,   N'ABC-Klasse Tschechien', N'ABC-Classe Czechia',           N'ABC-Klasse CZ:',              1, N'ABC', N'ID', 1, N'-1', N'-1', 1, N'ABC-Klassen Länder', 40, 1, 9245, 9245, N'SELECT ID, ABCBez FROM ABC WHERE Artikel = 1 ORDER BY ABC.ABC;'),
       (10236, 1014, N'_HRAbcID',           N'I', 0,   N'ABC-Klasse Kroatien',   N'ABC-Classe Croatia',           N'ABC-Klasse HR:',              1, N'ABC', N'ID', 1, N'-1', N'-1', 1, N'ABC-Klassen Länder', 40, 1, 9245, 9245, N'SELECT ID, ABCBez FROM ABC WHERE Artikel = 1 ORDER BY ABC.ABC;'),
       (10236, 1015, N'_HUAbcID',           N'I', 0,   N'ABC-Klasse Ungarn',     N'ABC-Class Hungary',            N'ABC-Klasse HU:',              1, N'ABC', N'ID', 1, N'-1', N'-1', 1, N'ABC-Klassen Länder', 40, 1, 9245, 9245, N'SELECT ID, ABCBez FROM ABC WHERE Artikel = 1 ORDER BY ABC.ABC;'),
       (10236, 1016, N'_PLAbcID',           N'I', 0,   N'ABC-Klasse Polen',      N'ABC-Class Poland',             N'ABC-Klasse PL:',              1, N'ABC', N'ID', 1, N'-1', N'-1', 1, N'ABC-Klassen Länder', 40, 1, 9245, 9245, N'SELECT ID, ABCBez FROM ABC WHERE Artikel = 1 ORDER BY ABC.ABC;'),
       (10236, 1017, N'_ROAbcID',           N'I', 0,   N'ABC-Klasse Rumänien',   N'ABC-Class Romania',            N'ABC-Klasse RO:',              1, N'ABC', N'ID', 1, N'-1', N'-1', 1, N'ABC-Klassen Länder', 40, 1, 9245, 9245, N'SELECT ID, ABCBez FROM ABC WHERE Artikel = 1 ORDER BY ABC.ABC;'),
       (10236, 1018, N'_RSAbcID',           N'I', 0,   N'ABC-Klasse Serbien',    N'ABC-Class Serbia',             N'ABC-Klasse RS:',              1, N'ABC', N'ID', 1, N'-1', N'-1', 1, N'ABC-Klassen Länder', 40, 1, 9245, 9245, N'SELECT ID, ABCBez FROM ABC WHERE Artikel = 1 ORDER BY ABC.ABC;'),
       (10236, 1019, N'_SIAbcID',           N'I', 0,   N'ABC-Klasse Slowenien',  N'ABC-Class Slovenia',           N'ABC-Klasse SI:',              1, N'ABC', N'ID', 1, N'-1', N'-1', 1, N'ABC-Klassen Länder', 40, 1, 9245, 9245, N'SELECT ID, ABCBez FROM ABC WHERE Artikel = 1 ORDER BY ABC.ABC;'),
       (10236, 1020, N'_SKAbcID',           N'I', 0,   N'ABC-Klasse Slowakei',   N'ABC-Class Slovakia',           N'ABC-Klasse SK:',              1, N'ABC', N'ID', 1, N'-1', N'-1', 1, N'ABC-Klassen Länder', 40, 1, 9245, 9245, N'SELECT ID, ABCBez FROM ABC WHERE Artikel = 1 ORDER BY ABC.ABC;');

INSERT INTO TabIndex (TabNameID, TagName, Expression, AnlageUserID_, UserID_)
VALUES (10236, N'_CHAbcID', N'_CHAbcID', 9245, 9245),
       (10236, N'_CZAbcID', N'_CZAbcID', 9245, 9245),
       (10236, N'_HRAbcID', N'_HRAbcID', 9245, 9245),
       (10236, N'_HUAbcID', N'_HUAbcID', 9245, 9245),
       (10236, N'_PLAbcID', N'_PLAbcID', 9245, 9245),
       (10236, N'_ROAbcID', N'_ROAbcID', 9245, 9245),
       (10236, N'_RSAbcID', N'_RSAbcID', 9245, 9245),
       (10236, N'_SIAbcID', N'_SIAbcID', 9245, 9245),
       (10236, N'_SKAbcID', N'_SKAbcID', 9245, 9245);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ ACHTUNG: Vor DB-Anpassungen folgenden Parameter dekativieren!                                                             ++ */
/* ++   KEEP_SAMPLE_RATE_ON_UPDATE_STATISTICS                                                                                   ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */